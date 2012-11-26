class Lexer

  def initialize(user_input)
    @user_input = user_input
  end

  # Create tokenize and create tokens object

  def tokens
    @tokens ||= tokenize_input
  end

  def tokenize_input
    token_list = []
    standardize_input
    tokenized_input = []
    statement.scan(/\S/).each do |token|
      case
      when token =~ /[A-Z]/
        tokenized_input << Token.new(:proposition, token.to_sym)
      when token =~ /[x\!\|\&\+\>]/
        tokenized_input << Token.new(token.to_sym)
      when token =~ /[\(]/
        tokenized_input << Token.new(:lparen)
      when token =~ /[\)]/
        tokenized_input << Token.new(:rparen)
      when token =~ /[\,]/
        tokenized_input << Token.new(:comma)
      else raise "Unexpected token: #{token}"
      end
    end
    tokenized_input
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
