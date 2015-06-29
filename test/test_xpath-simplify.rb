require 'minitest/autorun'
require 'xpath-simplify'

class XPathTest < Minitest::Test
  def test_id
    assert_equal "//*[@id='idname']",
                 XPathSimplify.simplify('#')
  end
=begin
  def test_class
    assert_equal "//*[contains(@class,'classname')]",
                 XPathSimplify.simplify('.classname')
  end

  def test_tag
    assert_equal "//li",
                 XPathSimplify.simplify('li')
    assert_equal "//ul",
                 XPathSimplify.simplify('ul')
    assert_equal "//a",
                 XPathSimplify.simplify('a')
    assert_equal "//button",
                 XPathSimplify.simplify('button')
    assert_equal "//span",
                 XPathSimplify.simplify('span')
    assert_equal "//input",
                 XPathSimplify.simplify('input')
  end

  def test_link
    assert_equal "//*[contains(@class,'classname')]",
                 XPathSimplify.simplify('htt')
    assert_equal "//*[contains(@class,'classname')]",
                 XPathSimplify.simplify('/')
    assert_equal "//*[contains(@class,'classname')]",
                 XPathSimplify.simplify('mailto')
  end

  def test_attach
    assert_equal "//li[4]",
                 XPathSimplify.simplify('li -> 3')
    assert_equal "//ul[6]",
                 XPathSimplify.simplify('ul -> 6')
    assert_equal "//*[contains(@class,'classname')][12]",
                 XPathSimplify.simplify('.classname -> 12')
  end

  def test_text_plain
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('This is a text test')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('The button test is here')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('Punctuation? Hopefully.')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('A span and a input')
  end

  def test_text_full
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify(':: This is a text test')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify(':: .classname #idname')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify(':: and or and or')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify(':: a span and a input')
  end

  def test_and
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('.classname1 && .classname2')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('#idname1 && .classname1')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('Text Here && .classname1')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('.classname1 && Text Here')
  end

  def test_or
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('.classname1 || .classname2')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('#idname1 || .classname1')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('Text Here || .classname1')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('.classname1 || Text Here')
  end

  def test_brackets
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('(( .classname ))')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('(( Text and other things ))')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('(( .classname1 .classname2 ))')
    assert_equal "//*[@id='remember-me']",
                 XPathSimplify.simplify('(( .classname1 Text is here ))')
  end
=end
end