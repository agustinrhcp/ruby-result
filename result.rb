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

  def to_hash
    { @result.first => @result.last }
  end

  def map
    case @result
    in [:ok, something]
      new_result = yield something
      self.class.ok(new_result)
    else
      self
    end
  end

  def then
    case @result
    in [:ok, something]
      yield something
    else
      self
    end
  end

  def ok?
    @result.first == :ok
  end

  def error?
    @result.first == :error
  end

  def when_ok(&block)
    ResultCase.when_ok(self, &block)
  end

  def when_error(&block)
    ResultCase.when_error(self, &block)
  end
end

class ResultCase
  def initialize(result, ok_block: nil, error_block: nil)
    @result = result
    @ok_block = ok_block
    @error_block = error_block
  end

  def self.when_ok(result, &block)
    new(result, ok_block: block)
  end

  def self.when_error(result, &block)
    new(result, error_block: block)
  end

  def when_ok(&block)
    @ok_block = block
    run
  end

  def when_error(&block)
    @error_block = block
    run
  end

  private

  def run
    case @result.to_hash
    in { ok: ok_value }
      @ok_block.call(ok_value)
    in { error: error_value }
      @error_block.call(error_value)
    end
  end
end
