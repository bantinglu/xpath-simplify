class XPathSimplify
  def self.simplify (str)
    arr = str.split(/ /)
    @f_and = false
    @f_or = false
    xp = convert(arr, false, false)
    return xp
  end

  def self.convert (arr, f_attach, f_text)
    xp = Array.new
    i = 0
    f_attach = "//*" unless f_attach
    begin
    while i < arr.length do
      case arr[i]
      when '(('    then i += 1; xp[i] = convert(arr[i..arr.length], false, f_text); xp[i] = append_previous(xp, i); i = bracket_increment(arr,i)
      when '))'    then return xp.join('')
      when '->'    then i += 1; xp[i] = "[#{arr[i]}]"
      when '>>'    then i += 1; f_attach = xp[i-1]
      when '&&'    then if f_text then @f_and = true; return xp.join(''); else i += 1; xp[i] = " and #{convert(arr[i..arr.length], false, false)}"; i+=1; end
      when '||'    then if f_text then @f_or = true; return xp.join(''); else i += 1; xp[i] = " or #{convert(arr[i..arr.length], false, false)}"; i+=1; end
      when '::'    then if f_text then return xp.join(''); else i+=2; xp[i] = "#{f_attach}[contains(text(),'#{arr[i-1]}#{convert(arr[i..arr.length], f_attach, true)}')]"; i = text_increment(arr,i); end
      else              if f_text then xp[i] = " #{arr[i]}"
        else
          case arr[i]
          when /^#.+/                                                           then xp[i] = "#{f_attach}[@id='#{arr[i][1..-1]}']";
          when /^\..+/                                                          then xp[i] = "#{f_attach}[contains(@class,'#{arr[i][1..-1]}')]";
          when 'li', 'ul', 'a', 'span', 'button', 'input', 'label', 'textarea'  then xp[i] = "//#{arr[i]}"
          when /^\/.+/, /^http.*/, /^mailto.*/                                  then xp[i] = "#{f_attach}[contains(@href,'#{arr[i]}')]";
          else i+=1;                                                                 xp[i] = "#{f_attach}[contains(text(),'#{arr[i-1]}#{convert(arr[i..arr.length], f_attach, true)}')]"; i = text_increment(arr,i); end
        end
      end
      if    @f_and then @f_and = false
      elsif @f_or  then @f_or = false
      else  i += 1 end
    end
    rescue then return xp.join('')
    end
    return xp.join('')
  end

  def self.text_increment(arr, i)
    while i < arr.length do
      if arr[i] === '::' || arr[i] === '&&' || arr[i] === '||' || arr[i] === '((' || arr[i] === '))' || arr[i] === '->' || arr[i] === '>>'  then return i
      else i+=1 end
    end
    return arr.length
  end

  def self.bracket_increment(arr, i)
    counter = 0
    while i < arr.length do
      if arr[i] === '((' then counter += 1
      elsif arr[i] === '))' then if counter == 0 then return i; else counter -=1; end
      else i+=1; end
    end
    return arr.length
  end

  def self.append_previous(xp, i)
    if i>1
      begin
      xp[i] = xp[i].gsub(' and //'," and #{xp[i-2]}//")
      xp[i] = xp[i].gsub(' or //'," or #{xp[i-2]}//")
      rescue
        # Do Nothing
     end
    end
    return xp[i]
  end
end

