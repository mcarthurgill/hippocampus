module Formatting
  
  def format_phone(number, calling_code="1")
    strip_whitespace!(number)
    prepare_calling_code!(calling_code)
    if number && number.first == "+"
      return "+"+strip_non_numeric!(number)
    elsif calling_code && calling_code.length > 0
      strip_non_numeric!(number)
      if number_has_calling_code?(number, calling_code)
        remove_calling_code!(number, calling_code)
      end
      remove_leading_zeros!(number)
      return "+"+add_calling_code(number, calling_code)
    end
    return "+"+number
  end

  def strip_whitespace!(number)
    number.gsub!(/\s+/, "")
  end

  def strip_non_numeric!(number)
    number.gsub!(/\D/, '')
  end

  def number_has_calling_code?(number, calling_code)
    number.slice(0...calling_code.length) == calling_code
  end

  def remove_calling_code!(number, calling_code)
    number.slice!(0...calling_code.length)
  end

  def remove_leading_zeros!(number)
    number.sub!(/^0+/, "")
  end

  def add_calling_code(number, calling_code)
    number.prepend(calling_code)
  end

  def prepare_calling_code!(calling_code)
    strip_whitespace!(calling_code)
    strip_non_numeric!(calling_code)
    return calling_code
  end


  def encrypt_password(string)
    return Digest::SHA1.hexdigest("#{string}sf098354sl#!^m$$yeaYou@a!")
  end

  def token_for_verification_text token
    i = token.index('(')
    j = token.index('==')
    length = j-i-1
    return token[i+1, length]
  end

end
