class Result
  def initialize(result)
    @result = result
  end

  def self.ok(successful_thing)
    new([:ok, successful_thing])
  end

  def self.error(errored_thing)
    new([:error, errored_thing])
  end

  def map
    case @result
    in [:ok, something]
      self.class.ok(yield something)
    else
      self
    end
  end

  def then
    case @result
    in [:ok, something]
      yield(something).tap do |returned_result|
        unless returned_result.is_a?(self.class)
          raise InvalidReturn, 'then handler must return a Result'
        end
      end
    else
      self
    end
  end

  def map_error
    case @result
    in [:error, something]
      self.class.error(yield something)
    else
      self
    end
  end

  def with_default(default)
    case @result
    in [:ok, something]
      yield something
    else
      yield default
    end
  end

  def ok?
    @result.first == :ok
  end

  def error?
    @result.first == :error
  end

  def when_ok(&block)
    Case.when_ok(self, &block)
  end

  private

  def to_hash
    { @result.first => @result.last }
  end

  class Case
    def initialize(result, ok_block:)
      @result = result
      @ok_block = ok_block
    end

    def self.when_ok(result, &block)
      new(result, ok_block: block)
    end

    def when_error(&block)
      case @result.send(:to_hash)
      in { ok: ok_value }
        @ok_block.call(ok_value)
      in { error: error_value }
        block.call(error_value)
      end
    end
  end

  class ResultError < StandardError; end
  class InvalidReturn < ResultError; end
end
