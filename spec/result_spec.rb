require 'spec_helper'
require './result'

describe Result do
  describe '.ok' do
    subject { described_class.ok(:ok) }

    it { is_expected.to be_kind_of(described_class) }
    it { is_expected.to be_ok }
  end

  describe '.error' do
    subject { described_class.error(:oops) }

    it { is_expected.to be_kind_of(described_class) }
    it { is_expected.to be_error }
  end

  describe '#map' do
    subject(:mapped) { result.map { |one| one * 2 } }

    context 'mapping over an ok result' do
      let(:result) { described_class.ok(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_ok }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 2 }
      end
    end

    context 'mapping over an error result' do
      let(:result) { described_class.error(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_error }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 1 }
      end
    end
  end

  describe '#then' do
    context 'when the handler does not return a result' do
      subject { ->() { Result.ok(:ok).then(&:itself) } }

      it { is_expected.to raise_error(Result::InvalidReturn) }
    end

    subject(:bound) { result.then { |one| Result.ok(one * 2) } }

    context 'then over an ok result' do
      let(:result) { described_class.ok(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_ok }

      describe 'the inner value' do
        subject { bound.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 2 }
      end


      context 'can return an error' do
        subject(:bound) { result.then { |one| Result.error(:some_error) } }

        it { is_expected.to be_kind_of(described_class) }
        it { is_expected.to be_error }

        describe 'the inner value' do
          subject { bound.when_ok(&:itself).when_error(&:itself) }

          it { is_expected.to be :some_error }
        end
      end
    end

    context 'then over an error result' do
      let(:result) { described_class.error(:some_error) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_error }

      describe 'the inner value' do
        subject { bound.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql :some_error }
      end
    end
  end

  describe '#with_default' do
    let(:result) { described_class.ok(1) }
    subject { result.with_default(0, &:itself) }

    it { is_expected.to eql 1 }

    context 'with an error result' do
      let(:result) { described_class.error(1, &:itself) }

      it { is_expected.to eql 0 }
    end
  end

  describe '#map_error' do
    subject(:mapped) do
      result.map_error { |error| "Oops: #{error}" }
    end

    context 'mapping over an ok result' do
      let(:result) { Result.ok(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_ok }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 1 }
      end
    end

    context 'mapping over an error result' do
      let(:result) { Result.error("An error :O") }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_error }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql "Oops: An error :O" }
      end
    end
  end

  describe '#when_ok.when_error' do
    let(:result) { Result.ok(:cool) }

    context 'ok result' do
      subject { result.when_ok(&:itself).when_error { :error } }

      it { is_expected.to eql :cool }
    end

    context 'error result' do
      let(:result) { Result.error(:not_cool) }

      subject { result.when_ok { :cool }.when_error(&:itself) }

      it { is_expected.to eql :not_cool }
    end

    describe 'when_ok' do
      subject { result.when_ok(&:itself) }

      it { is_expected.to be_kind_of(Result::Case) }
    end
  end
end
