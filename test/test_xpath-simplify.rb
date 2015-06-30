require 'minitest/autorun'
require 'xpath-simplify'

class XPathTest < Minitest::Test

  def test_id
    assert_equal "//*[@id='idname']",
                 XPathSimplify.simplify('#idname')
  end
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
    assert_equal "//*[contains(@href,'http://www.google.com')]",
                 XPathSimplify.simplify('http://www.google.com')
    assert_equal "//*[contains(@href,'https://www.google.com')]",
                 XPathSimplify.simplify('https://www.google.com')
    assert_equal "//*[contains(@href,'/selection')]",
                 XPathSimplify.simplify('/selection')
    assert_equal "//*[contains(@href,'/selection/selection2')]",
                 XPathSimplify.simplify('/selection/selection2')
    assert_equal "//*[contains(@href,'mailto:bob@joe.com')]",
                 XPathSimplify.simplify('mailto:bob@joe.com')
  end

  def test_attach
    assert_equal "//li[3]",
                 XPathSimplify.simplify('li -> 3')
    assert_equal "//ul[6]",
                 XPathSimplify.simplify('ul -> 6')
    assert_equal "//*[contains(@class,'classname')][12]",
                 XPathSimplify.simplify('.classname -> 12')
  end


  def test_text_plain
    assert_equal "//*[contains(text(),'This is a text test')]",
                 XPathSimplify.simplify('This is a text test')
    assert_equal "//*[contains(text(),'The button test is here')]",
                 XPathSimplify.simplify('The button test is here')
    assert_equal "//*[contains(text(),'Punctuation? Hopefully.')]",
                 XPathSimplify.simplify('Punctuation? Hopefully.')
    assert_equal "//*[contains(text(),'A span and a input')]",
                 XPathSimplify.simplify('A span and a input')
  end

  def test_text_full_front
    assert_equal "//*[contains(text(),'This is a text test')]",
                 XPathSimplify.simplify(':: This is a text test')
    assert_equal "//*[contains(text(),'Text  with some weird    spacing')]",
                 XPathSimplify.simplify(':: Text  with some weird    spacing')
    assert_equal "//*[contains(text(),'and or and or')]",
                 XPathSimplify.simplify(':: and or and or')
    assert_equal "//*[contains(text(),'a span and a input')]",
                 XPathSimplify.simplify(':: a span and a input')
  end

  def test_text_full_middle
    assert_equal "//*[contains(text(),'This is a text test')]//*[contains(@class,'classname')]",
                 XPathSimplify.simplify(':: This is a text test :: .classname')
    assert_equal "//*[contains(@class,'classname')]//*[contains(text(),'This is a text test')]",
                 XPathSimplify.simplify('.classname :: This is a text test ::')
  end

  def test_text_full_middle_nested
    assert_equal "//*[@id='idname1']//*[contains(text(),'This is a text test')]//*[contains(@class,'classname')]",
                 XPathSimplify.simplify('#idname1 :: This is a text test :: .classname')
    assert_equal "//*[contains(text(),'Some Text Here')]//*[contains(text(),'This is a text test')]//*[contains(text(),'And the end')]",
                 XPathSimplify.simplify(':: Some Text Here :: :: This is a text test :: :: And the end ::')
  end

  def test_and
    assert_equal "//*[contains(@class,'classname1')] + //*[contains(@class,'classname2')]",
                 XPathSimplify.simplify('.classname1 && .classname2')
    assert_equal "//*[@id='idname1'] + //*[contains(@class,'classname1')]",
                 XPathSimplify.simplify('#idname1 && .classname1')
    assert_equal "//*[contains(text(),'Text Here')] + //*[contains(@class,'classname1')]",
                 XPathSimplify.simplify(':: Text Here :: && .classname1')
    assert_equal "//*[contains(@class,'classname1')] + //*[contains(text(),'Text Here')]",
                 XPathSimplify.simplify('.classname1 && :: Text Here ::')
    end

  def test_or
    assert_equal "//*[contains(@class,'classname1')] | //*[contains(@class,'classname2')]",
                 XPathSimplify.simplify('.classname1 || .classname2')
    assert_equal "//*[@id='idname1'] | //*[contains(@class,'classname1')]",
                 XPathSimplify.simplify('#idname1 || .classname1')
    assert_equal "//*[contains(text(),'Text Here')] | //*[contains(@class,'classname1')]",
                 XPathSimplify.simplify(':: Text Here :: || .classname1')
    assert_equal "//*[contains(@class,'classname1')] | //*[contains(text(),'Text Here')]",
                 XPathSimplify.simplify('.classname1 || :: Text Here ::')
  end

  def test_brackets
    assert_equal "//*[contains(@class,'classname')]",
                 XPathSimplify.simplify('(( .classname ))')
    assert_equal "//*[contains(@class,'classname')]//*[@id='idname']",
                 XPathSimplify.simplify('(( .classname #idname ))')
    assert_equal "//*[contains(@class,'classname')]//*[@id='idname']//*[@id='idname2']",
                 XPathSimplify.simplify('(( .classname )) (( #idname )) (( #idname2 ))')
    assert_equal "//*[contains(@class,'classname') and @id='idname']",
                 XPathSimplify.simplify('(( .classname && #idname ))')
    assert_equal "//*[contains(@class,'classname')] + //*[@id='idname']",
                 XPathSimplify.simplify('(( .classname )) && (( #idname ))')
    assert_equal "//*[contains(@class,'classname')]//*[@id='idname1' and @id='idname2']",
                 XPathSimplify.simplify('.classname (( #idname1 && #idname2 ))')
    assert_equal "//*[contains(@class,'classname')]//*[@id='idname1' or @id='idname2']",
                 XPathSimplify.simplify('.classname (( #idname1 || #idname2 ))')
  end

  def test_advanced
    assert_equal "//*[contains(@class,'classname1') or contains(@class,'classname2')][12]//*[contains(text(),'Test This here')]",
                 XPathSimplify.simplify('(( .classname1 || .classname2 )) -> 12 :: Test This here ::')
    assert_equal "//*[contains(@class,'classname1') or contains(@class,'classname2')][12]//*[contains(text(),'There is a lot of text here')]",
                 XPathSimplify.simplify('(( .classname1 || .classname2 )) -> 12 :: There is a lot of text here ::')
  end

end