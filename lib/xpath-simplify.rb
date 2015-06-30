class XPathSimplify
  def self.simplify (str)
    arr = str.split(/ /)
    xp = assemble(arr)
    return xp
  end

  def self.assemble(arr)
    return "//*[contains(text(),'#{arr.join(' ')}')]" if check_only_text(arr)
    arr.each_with_index do |a,i|
      case a
      when '((', '))', '->', '>>', '&&', '||', '::'                         then next
      when /^#.+/                                                           then arr[i] = "//*[@id='#{arr[i][1..-1]}']";
      when /^\..+/                                                          then arr[i] = "//*[contains(@class,'#{arr[i][1..-1]}')]";
      when /\/[^\/].+/, /^http.*/, /^mailto.*/                              then arr[i] = "//*[contains(@href,'#{arr[i]}')]";
      else                                                                       next
      end
    end
    arr = combine_words(arr)
    arr.each_with_index do |a,i|
      case a
      when 'li', 'ul', 'a', 'span', 'button', 'input', 'label', 'textarea'  then arr[i] = "//#{arr[i]}";
      else                                                                       next
      end
    end
    arr = evaluate_array(arr, true)
    return arr.join('')
  end

  def self.check_only_text(arr)
    arr.each do |a|
      case a
      when '((', '))', '->', '>>', '&&', '||', '::'                       then return false
      else                                                                     next
      end
    end
    case arr[0]
    when '((', '))', '->', '>>', '&&', '||', '::', /^#.+/, /^\..+/        then return false
    when 'li', 'ul', 'a', 'span', 'button', 'input', 'label', 'textarea'  then return false
    when /\/[^\/].+/, /^http.*/, /^mailto.*/                              then return false
    else                                                                       return true
    end
  end

  def self.combine_words(arr)
    f_text = -1
    arr.each_with_index do |a,i|
      case a
      when '((', '))', '->', '>>', '&&', '||'                               then next
      when /^\/\/\*.+/                                                      then next
      when '::'
        if f_text != -1
          arr[f_text] = arr[f_text][0..-2].to_s + "')]"
          f_text = -1
          arr[i] = nil
        else
          f_text = i
          arr[i] = "//*[contains(text(),'"
        end
      else
        if f_text != -1
          arr[f_text] = arr[f_text].to_s + arr[i].to_s + ' '
          arr[i] = nil
        else
          next
        end
      end
    end
    if f_text != -1 then arr[f_text] = arr[f_text][0..-2].to_s + "')]"; end;
    return arr.compact
  end

  def self.evaluate_array(arr,toplevel = false)
    arr = arr.compact
    arr.each_with_index do |a,i|
      case a
      when nil     then next
      when '(('
        targ = 0
        arr[(i+1)..arr.length].each_with_index do |b,j|
          if b == '))'
            targ = i+j+1
            break
          end
        end
        arr[i]=nil
        arr[targ]=nil
        temp = evaluate_array(arr[i+1..targ])
        for j in (0...temp.length) do
          arr[i+j] = temp[j];
        end
        for j in (i+temp.length)..(targ) do
          arr[j] = nil
        end
      when '))'    then return arr
      else              next
      end
    end

    arr = arr.compact
    arr.each_with_index do |a,i|
      case a
      when '->'    then arr = evaluate_index(arr,i)
      else         next
      end
    end

    arr = arr.compact
    arr.each_with_index do |a,i|
      case a
      when '>>'    then arr = evaluate_attach(arr,i)
      else         next
      end
    end

    arr = arr.compact
    arr.each_with_index do |a,i|
      case a
      when '&&'    then arr = evaluate_and(arr,i,toplevel)
      when '||'    then arr = evaluate_or(arr,i,toplevel)
      else         next
      end
    end

    return arr
  end

  def self.evaluate_index(arr,i)
    arr[i] = "#{arr[i-1]}[#{arr[i+1]}]"
    arr[i-1] = nil
    arr[i+1] = nil
    return arr
  end

  def self.evaluate_attach(arr,i)
    arr[i] = "#{arr[i-1]}#{arr[i+1][3..-1]}"
    arr[i-1] = nil
    arr[i+1] = nil
    return arr
  end

  def self.evaluate_and(arr,i,flag = false)
    if flag then arr[i] = "#{arr[i-1]} + //*#{arr[i+1][3..-1]}"
    else         arr[i] = "#{arr[i-1][0..-2]} and #{arr[i+1][4..-1]}"
    end
    arr[i-1] = nil
    arr[i+1] = nil
    return arr
  end

  def self.evaluate_or(arr,i,flag = false)
    if flag then arr[i] = "#{arr[i-1]} | //*#{arr[i+1][3..-1]}"
    else         arr[i] = "#{arr[i-1][0..-2]} or #{arr[i+1][4..-1]}"
    end
    arr[i-1] = nil
    arr[i+1] = nil
    return arr
  end
end