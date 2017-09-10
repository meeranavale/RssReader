# This class is responsible for storing feeds
require 'rss'
require 'open-uri'

class Feed < ActiveRecord::Base
  validates :url, uniqueness: true, presence: true
  validate :validate_url_format

  # Parse all available feeds using rss and open_uri modules of ruby
  # @return [Array] of hash containing sorted parsed data
  # @example posts_data array
  #   [ [ {:title=>"Support of Ruby 2.1 has ended",
  #      :pub_date=>2017-04-01 00:00:00 +0000,
  #      :link=>"https://www.ruby-lang.org/en/news/2017/04/01/support-of-ruby-2-1-has-ended/"} ]
  def self.parse_feeds
    return [] unless Feed.any?

    posts_data = []
    begin
       Feed.all.each do |feed|
         open(feed.url) do |rss|
           parsed_feed = RSS::Parser.parse(rss)
           parsed_feed.items.each do |item|
             posts_data << { title: item.title, pub_date: item.pubDate, link: item.link }
           end
         end
       end

       # Sort posts in descending order of pub_date
       posts_data.sort { |post_1, post_2| post_2[:pub_date] <=> post_1[:pub_date] }
     rescue Exception => e
       # log exception here
     end
  end

  private

  # Validates fee url, if invalid then adds an error to the instance
  def validate_url_format
    valid_url = false
    begin
      uri = URI.parse(url)
      valid_url = uri.scheme.present? || uri.host.present?
    rescue URI::InvalidURIError
      valid_url = false
    end
    errors.add(:url, 'format is invalid') unless valid_url
  end
end
