class XPathSimplify
  def self.hi
    return 'Hi'
  end

  def self.simplify (str)
    arr = str.split(/ /)
    xp = Array.new
    xp = convert(arr)
    return xp.join('')
  end

  def self.convert (arr)
    xp = Array.new
    f_text = false
    f_attach = "//*"
    f_and = false
    f_or = false
    i = 0
    begin
    while i <= arr.length do
      case arr[i]
      when '(('    then xp[i] = convert(arr[i..arr.length])
      when '))'    then return xp
      when '->'    then i += 1; xp[i] = "[#{arr[i]}]"
      when '>>'    then i += 1; f_attach = xp[i-1]
      when '&&'    then i += 1; f_and = xp[i]
      when '||'    then i += 1; f_or = xp[i]
      when '::'    then
        if f_text  then f_text = false; return xp
        else            f_text = true; xp[i] = convert(arr[i..arr.length]);
        end
      when '.'     then xp[i] = "#{f_attach}[contains(@class,'#{arr[i]}']"; f_attach = "//*"
      when '#'     then xp[i] = "#{f_attach}[@id='#{arr[i]}']"; f_attach = "//*"
      when 'tag'   then xp[i] = "#{arr[i]}"
      when 'link'  then xp[i] = "#{f_attach}[contains(@href,'#{arr[i]}']"; f_attach = "//*"
      else
        if f_text  then xp[i] = "//#{arr[i]}"
        else            i += 1; f_text = true; xp[i] = "#{f_attach}[contains(text(),'#{convert(arr[i..arr.length])}')]"; f_attach = "//*"
        end
      end
      i += 1
    end
    rescue
      return xp
    end
    return xp
  end
end