# Resque::Delayed

Delayed job queueing for Resque.

Enqueue jobs that will only appear for processing after a specified delay or at a particular time in the future.

## About

Useful for jobs that would be awkward to run in crons. For example:

* expiring stale orders to free up reserved inventory
* retrying failed webhook deliveries with progressively increasing delays

Also useful for jobs that are typically run in crons. For example:

* sending call-to-action reminder emails a few days after each signup
* checking whether pending payments have cleared

Fine-grained job scheduling avoids the need for monolithic crons that are often slow, resource intensive and single-process. Instead of needing to stagger crons to avoid overlap or parallelize crons that are too slow, jobs can be spread throughout the entire day and amongst multiple worker processes.

## Usage

Resque::Delayed is very simple. Call `Resque.enqueue_in` or `Resque.enqueue_at` instead of `Resque.enqueue`
For example:

```ruby
class User
  after_create :send_call_to_action_email

  private
  def send_call_to_action_email
    Resque.enqueue_in 3.days, CallToActionEmailJob, self.id
  end
end
```

**or**

```ruby
class RecurringInvoice
  def generate_invoice
    # snip...

    Resque.enqueue_at self.next_billing_date, RecurringInvoiceJob, self.id
  end
end
```

**or**

```ruby
class Webhook
  MAX_RETRIES = 15

  def deliver
    unless Webhook.post(payload).success?
      return if retries == Webhook::MAX_RETRIES

      update_attribute :retries, retries + 1

      Resque.enqueue_in (2**retries).minutes, WebhookDeliveryJob, self.id
    end
  end
end
```

## Setup

`$ gem install resque-delayed`

or add

`gem 'resque-delayed'`

to your Gemfile and run

 `$ bundle install`

Resque::Delayed piggybacks on your existing Resque setup so it will use whatever Redis instance Resque has been configured to use.

The above will provide `Resque.enqueue_in` and `Resque.enqueue_at` to your application but you will also need to run a Resque::Dealyed worker process. The worker is responsible for harvesting future-queued jobs and pushing them onto the appropriate Resque queues at the right time.

`Resque::Delayed::Worker` is a stripped-down version of `Resque::Worker` so you can use the same configuration options like `INTERVAL`, `PIDFILE`, `LOGGING`, `VERBOSE` and `VVERBOSE`

Like Resque, Resque::Delayed provides a rake task to run workers. Add `require 'resque-delayed/tasks'` to your `Rakefile` and run

    $ cd app_root
    $ LOGGING=1 INTERVAL=10 rake resque_delayed:work

**NOTE: Resque::Delayed workers only take future-queued jobs and push them onto Resque queues when they need to be run. They do *not* actually process jobs so any setup using Resque::Delayed also needs one or more regular Resque workers.**

## Deployment Considerations

Resque::Delayed workers are very lean as they do not need to load either your application or your Resque job classes. Even so you will probably want to monitor them in production using something like monit, god, or bluepill. Also, because they are not actually performing any of the job processing work it is unlikely you will need to run more than one.<sup>1</sup>

<sup>1</sup> a single Resque::Delayed worker on a laptop with unexciting hardware can push a few thousand jobs per second into Resque while new delayed jobs are simultaneously being added.

## Contributing

1. [fork](http://help.github.com/fork-a-repo/) this repo
1. create a topic branch (`$ git checkout -b my_branch`)
1. make your changes along with specs
1. push to your branch (`$ git push origin my_branch`)
1. send me a [pull request](http://help.github.com/send-pull-requests/)

## Thanks

Thanks to [defunkt](https://github.com/defunkt) and all Resque contributors. Resque is a pleasure to use and adapts well to new challenges. Also some code in this project, `Resque::Delayed::Worker` in particular, borrows heavily from the Resque implementation.

## Copyright

Copyright (c) Justin Giancola. See LICENSE for details.