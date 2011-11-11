require 'augeas'

Puppet::Type.type(:sensu_check_subscribers).provide :augeas do
  desc "augeas logic to manage sensu check subscriptions"

  confine :true => File.exists?("/usr/share/augeas/lenses/sensu.aug")

  def initialize(*args)
    super
    @aug = Augeas::open(nil, nil, Augeas::NO_MODL_AUTOLOAD)
    @aug.transform(:lens => 'Sensu.lns', :incl => '/etc/sensu/config.json')
    @aug.load
    @context = "/files/etc/sensu/config.json/dict/entry[.='checks']/dict"
  end

  def subscribers=(value)
    @aug.load

    unless @aug.exists "#{@context}/entry[.='#{resource[:check]}']/dict/entry[.='subscribers']"
      @aug.set "#{@context}/entry[.='#{resource[:check]}']/dict/entry[last()+1]", 'subscribers'
    end

    keys = @aug.match("#{@context}/entry[.='#{resource[:check]}']/dict/entry[.='subscribers']/array/*")
    current_subscribers = keys.map { |key| @aug.get(key) }
    current_subscribers.each do |subscription|
      unless value.include? subscription
        Puppet.info "Purging unknown subscription '#{subscription}' on '#{resource[:check]}' check"
        @aug.rm "#{@context}/entry[.='#{resource[:check]}/dict/entry[.='subscribers']/array/string[.='#{subscription}']"
      end
    end

    value.each do |subscription|
      unless current_subscribers.include? subscription
        Puppet.info "Adding '#{subscription}' subscription to '#{resource[:check]}' check"
        @aug.set "#{@context}/entry[.='#{resource[:check]}/dict/entry[.='subscribers']/array/string[last()+1]", subscription
      end
    end

    unless @aug.save
      Puppet.err "Save failed"
      err = @aug.match "/augeas/files/etc/sensu/config.json/error/*"
      err.each do |e|
        Puppet.err "#{File.basename(e)}: #{@aug.get(e)}"
      end
    end
  end

  def subscribers
    keys = @aug.match("#{@context}/entry[.='test']/dict/entry[.='subscribers']/array/*")
    current_subscribers = keys.map { |key| @aug.get(key) }
    current_subscribers.sort
  end

  def create
  end

  def destroy
  end

  def exists?
    true
  end
end
