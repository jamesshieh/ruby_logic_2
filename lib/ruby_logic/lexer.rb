class Lexer

  def initialize(user_input)
    @user_input = user_input
  end

  # Create tokenize and create tokens object

  def tokenize_input
    standardize_input
    tokens = Tokens.new
    @user_input.scan(/\S/).map do |token|
      case
      when token =~ /[A-Z]/
        tokens << Token.new(token.to_sym, :proposition)
      when token =~ /[x\!\|\&\+\>]/
        tokens << Token.new(token.to_sym)
      when token =~ /[\(]/
        tokens << Token.new(:lparen)
      when token =~ /[\)]/
        tokens << Token.new(:rparen)
      else raise "Unexpected token: #{token}"
      end
    end
    tokens
  end

  private

  # Standardize input across all different allowed symbols

  def standardize_input
    valid_characters = Regexp.new(/\A[A-Zvx\^\&\!\~\|\-\>\<\(\)\ \[\]\{\}\,\+]*\z/)
    if @user_input =~ valid_characters
      @user_input = @user_input.dup
      @user_input.gsub!(/v/, "|")
      @user_input.gsub!(/\^/, "&")
      @user_input.gsub!(/\~/, "!")
      @user_input.gsub!(/\-\>/, ">")
      @user_input.gsub!(/\<\-/, "<")
      @user_input.gsub!(/\[\{/, "(")
      @user_input.gsub!(/\]\}/, ")")
      @user_input.gsub!(/\<\-\>/, "+")
      @user_input.gsub!(/\<\>/, "+")
      @user_input
    else
      raise "Invalid characters in input"
    end
  end

end
