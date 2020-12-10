require 'spec_helper'

RSpec.describe NsClient::Slack::AttachmentBuilder do
  let(:color) { 'danger' }
  let(:fallback_text) { 'fallback text' }
  let(:pretext) { 'pretext' }
  let(:text) { 'A text.' }
  let(:title) { 'A Title' }
  let(:title_url) { 'https://hungerstation.com' }
  let(:field_name) { 'Field 1' }
  let(:field_value) { 'some value' }
  subject do
    NsClient::Slack::AttachmentBuilder.build.
      with_color(color).
      with_fallback_text(fallback_text).
      with_pretext(pretext).
      with_text(text).
      with_title(title).
      with_title_link(title_url).
      add_field(field_name, field_value)
  end

  describe '#with_color' do
    it 'sets color' do
      expect(subject.attachment.color).to eq color
    end
  end

  describe '#with_fallback_text' do
    it 'sets fallback text' do
      expect(subject.attachment.fallback).to eq fallback_text
    end
  end

  describe '#with_pretext' do
    it 'sets pretext' do
      expect(subject.attachment.pretext).to eq pretext
    end
  end

  describe '#with_text' do
    it 'sets text' do
      expect(subject.attachment.text).to eq text
    end
  end

  describe '#with_title' do
    it 'sets title' do
      expect(subject.attachment.title).to eq title
    end
  end

  describe '#with_title_link' do
    it 'sets color' do
      expect(subject.attachment.title_link).to eq title_url
    end
  end

  describe '#add_field' do
    it 'sets field fields correctly' do
      expect(subject.attachment.fields[0].title).to eq field_name
      expect(subject.attachment.fields[0].value).to eq field_value
    end

    it 'appends new field' do
      expect {
        subject.add_field('Field 2', 'other value')
      }.to change { subject.attachment.fields.size }.by 1
    end
  end
end
