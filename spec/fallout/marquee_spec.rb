require "spec_helper"

describe Fallout::Marquee do
  let(:spi) { stub!.tx }

  before { stub(spi).tx }

  context "right to left" do
    let(:marquee) { Fallout::Marquee.new(spi, :dir => Fallout::Marquee::RIGHT_TO_LEFT) }

    describe "#start_message" do
      before { marquee.start_message("foo bar") }

      it "should set the current message" do
        marquee.current_message.should == "foo bar"
      end

      it "should set the initial x position to the far right" do
        marquee.x_pos.should == Fallout::Marquee::WIDTH
      end
    end

    describe "#tick" do
      before do
        marquee.start_message("foo bar")
        marquee.tick
      end

      it "should move the text to the left" do
        marquee.x_pos.should == Fallout::Marquee::WIDTH - 1
      end

      context "past the end of the message" do

      end
    end
  end

  context "left to right" do
    let(:marquee) { Fallout::Marquee.new(spi, :dir => Fallout::Marquee::LEFT_TO_RIGHT) }

    describe "#start_message" do
      before { marquee.start_message("foo bar") }

      it "should set the initial x position to the far left" do
        marquee.x_pos.should == -marquee.text_extents.width.to_i
      end
    end

    describe "#tick" do
      before do
        marquee.start_message("foo bar")
        marquee.tick
      end

      it "should move the text to the left" do
        marquee.x_pos.should == -marquee.text_extents.width.to_i + 1
      end
    end
  end
end
