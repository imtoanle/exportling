RSpec::Matchers.define :define_abstract_method do |method_name|
  match do |klass|
    return false unless klass.method_defined? method_name
    raise_not_implemented?(klass, method_name)
  end

  failure_message do |klass|
     "expected #{klass}##{method_name} to raise a NotImplementedError"
  end

  def raise_not_implemented?(klass, method_name)
    arg_count = klass.instance_method(method_name).arity

    if arg_count > 0
      klass.new.send(method_name, *Array.new(arg_count))
    else
      klass.new.send(method_name)
    end

    # Error hasn't been raised if we've made it here, so the method isn't a proper abstract method
    return false

  rescue NotImplementedError
    return true
  end
end
