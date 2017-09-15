class Book < ApplicationRecord
  include SearchCop
  acts_as_taggable_on :labels
  acts_as_taggable

  search_scope :search do
    attributes :name, :description
  end

  search_scope :title_search do
    attributes :name
  end

  # いま本がどこにあるのかわかるようにする
  belongs_to :where, class_name: 'User', foreign_key: 'user_id'
  has_many :favorites
  has_many :users, through: :favorites
  has_one :rental


  def self.import(file)
    counter = 0
    default_user = User.where(name: ENV['ADMINISTRATOR_NAME'])
    CSV.foreach(file.path, encoding: Encoding::SHIFT_JIS) do |row|
      unless self.exists?(isbn_13: row[2].to_i)
        create(isbn_13: row[2].to_i, isbn_10: row[1], name: row[11],
             publisher: row[13], author: row[12], publish_year: row[14].to_i,
             pages: row[16].to_i, user_id: default_user.ids[0])
        counter += 1
      end
    end
    counter
  end

  def self.import_from_api
    books = BookLog::Api.new(100).get_data
    default_user = User.where(name: ENV['ADMINISTRATOR_NAME'])
    books.each do |book|
      image_url = book[:image].sub('._SL75_', '')
      if self.exists?(book[:asin])
        create(author: book[:author], isbn_10: book[:asin], name: book[:title],
                               image_url: image_url, user_id: default_user.ids)
        puts 'success'
      end
    end
  end

  def self.ja_search(query)
    results = self.search(query)
    if query.present?
      size = results.size
      # 全角スペース置換
      query.gsub!('　', ' ')

      # 一単語のみで検索しているか
      unless query.include?(' ')
        okura = WordManipulation::OkuraConnector.new
        # queryが一般名詞のみで構成されているか
        if okura.is_noun?(query)
          if size > 3 && size < self.all.size
            un_tagged_books = results - Book.tagged_with(query)
            un_tagged_books.each do |book|
              book.tag_list.add(query)
              book.save
            end
          end
        end
      end
    end
    results
  end

  def self.ja_title_search(query)
    results = self.title_search(query)
    if query.present?
      size = results.size
      # 全角スペース置換
      query.gsub!('　', ' ')
    end
    results
  end
end
