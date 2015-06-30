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
    puts arr.to_s
    arr = evaluate_array(arr)
    puts arr.to_s
    arr = expand_or(arr)
    puts arr.to_s
    puts '______'
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
    else                                                                  puts 'no match';return true
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

  def self.expand_and(arr)
    counter = Array.new
    arr = arr.compact
    newarr = Array.new
    arr.each_with_index do |a,i|
      newarr[i] = a.to_s.split(' and //')
      newarr[i][1] = "//#{newarr[i][1]}" if newarr[i].size > 1
      counter.push(i) if newarr[i].size > 1
    end
    for i in 0..newarr.size-2 do
      newarr[0] = (newarr[0].product(newarr[i+1]).map {|x| x.flatten.join('')})
    end
    for i in 0..counter.size-1 do
      newarr[0].insert(counter[i],to_i, ' and ')
    end
    return newarr[0].flatten
  end

  def self.expand_or(arr)
    counter = Array.new
    arr = arr.compact
    newarr = Array.new
    arr.each_with_index do |a,i|
      newarr[i] = a.to_s.split(' or //')
      newarr[i][1] = "//#{newarr[i][1]}" if newarr[i].size > 1
      counter.push(i+1) if newarr[i].size > 1
    end
    for i in 0..newarr.size-2 do
      newarr[0] = (newarr[0].product(newarr[i+1]).map {|x| x.flatten.join('')})
    end
    for i in 0..counter.size-1 do
      newarr[0].insert(counter[i].to_i, ' or ')
    end
    return newarr[0].flatten
  end

  def self.evaluate_array(arr)
    arr = arr.compact
    arr.each_with_index do |a,i|
      puts 'AT'+ i.to_s + 'AND THIS' + arr.to_s
      case a
      when nil     then next
      when '(('
        targ = 0
        arr[(i+1)..arr.length].each_with_index do |b,j|
          if b == '))'
            targ = j
            break
          end
        end
        temp = evaluate_array(arr[i+1..i+targ])
        for j in (0...temp.length) do
          arr[i+j] = temp[j];
        end
        for j in (i+temp.length)..(i+targ) do
          arr[j] = nil
        end
      when '))'    then arr[i]=nil; return arr
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
      when '&&'    then arr = evaluate_and(arr,i)
      when '||'    then arr = evaluate_or(arr,i)
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

  def self.evaluate_and(arr,i)
    arr[i] = "#{arr[i-1]} and //*#{arr[i+1][3..-1]}"
    arr[i-1] = nil
    arr[i+1] = nil
    return arr
  end

  def self.evaluate_or(arr,i)
    arr[i] = "#{arr[i-1]} or //*#{arr[i+1][3..-1]}"
    arr[i-1] = nil
    arr[i+1] = nil
    return arr
  end
end