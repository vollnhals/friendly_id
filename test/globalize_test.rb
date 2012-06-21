# encoding: utf-8

require "helper"

class TranslatedArticle < ActiveRecord::Base
  translates :slug, :title
  extend FriendlyId
  friendly_id :title, :use => :globalize
end

class GlobalizeTest < MiniTest::Unit::TestCase
  include FriendlyId::Test

  test "friendly_id should find slug in current locale if locale is set, otherwise in default locale" do
    transaction do
      I18n.default_locale = :en
      article_en = I18n.with_locale(:en) { TranslatedArticle.create(:title => 'a title') }
      article_de = I18n.with_locale(:de) { TranslatedArticle.create(:title => 'titel') }

      I18n.with_locale(:de) {
        assert_equal TranslatedArticle.find("titel"), article_de
        assert_equal TranslatedArticle.find("a-title"), article_en
      }
    end
  end

  # https://github.com/svenfuchs/globalize3/blob/master/test/globalize3/dynamic_finders_test.rb#L101
  # see: https://github.com/svenfuchs/globalize3/issues/100
  test "record returned by friendly_id should have all translations" do
    transaction do
      I18n.with_locale(:en) do
        article = TranslatedArticle.create(:title => 'a title')
        Globalize.with_locale(:ja) { article.update_attributes(:title => 'タイトル') }
        article_by_friendly_id = TranslatedArticle.find("a-title")
        article.translations.each do |translation|
          assert_includes article_by_friendly_id.translations, translation
        end
      end
    end
  end
end

class GlobalizeRegressionTest < MiniTest::Unit::TestCase

  include FriendlyId::Test

  def setup
    I18n.locale = :en
  end

  test "should not raise NoMethodError when searching by non-current locale" do
    transaction do
      TranslatedArticle.destroy_all
      I18n.with_locale(:en) {TranslatedArticle.create(:title => 'a title')}
      article = TranslatedArticle.find('a-title')
      Globalize.with_locale(:es) { article.update_attributes(:title => 'un título') }
      I18n.locale = :en
      slug_en = TranslatedArticle.first.slug
      I18n.locale = :es
      slug_es = TranslatedArticle.first.slug
      assert TranslatedArticle.find slug_es
      assert TranslatedArticle.find slug_es
      assert TranslatedArticle.find slug_en
      assert_empty TranslatedArticle.where :slug => slug_en
      refute_empty TranslatedArticle.where :slug => slug_es
    end
  end
end
