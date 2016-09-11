require_relative "../spec_helper"

describe Question do
  before(:each) do
    @tournament = Factory(:tournament, :default_avg_time => 11)
    @question = Factory(:question)
    @quiz = Factory(:quiz)
  end

  it "returns questions with required difficulty" do
    Question.with_difficulty(1).map(&:difficulty).should == [1]
    Question.with_difficulty(2).map(&:difficulty).should == []
  end

  it "returns questions which user has not yet answered" do
    Question.for(@quiz.user).should == [@question]
    @answer = Factory(:answer, :user => @quiz.user, :question => @question, :tournament => @quiz_game, :quiz => @quiz)
    Question.for(@quiz.user).should == []    
  end

  it "returns [] if user has answered all questions with chosen difficulty" do
    @question2 = Factory(:question, :difficulty => 2)
    @answer = Factory(:answer, :user => @quiz.user, :question => @question, :tournament => @quiz_game, :quiz => @quiz)
    Question.for(@quiz.user).should == [@question2]
    Question.for(@quiz.user).with_difficulty(1).should == []    
  end

  it "returns tournament's default avg time if question avg time is not set" do
    @question.avg_time.should == 11
  end

  it "returns question avg time if available" do
    @question.update_attribute :avg_time, 10
    @question.avg_time.should == 10
  end

  describe "#wrong_answers" do
    it "should accept and parse array" do
      @question.wrong_answers = %w(Tim Tom Todd)
      @question.wrong_answers.should == %w(Tim Tom Todd)
    end
    it "should accept and parse string" do
      @question.wrong_answers = "Tim \n Tom \n Todd"
      @question.wrong_answers.should == %w(Tim Tom Todd)
    end
    it "should validate wrong answers number" do
      @question.wrong_answers = "Tim"
      @question.save.should == false
    end
  end

  describe "#randomised_answers" do
    it "should return 3 answers" do
      @question.randomised_answers.size.should == 3
    end

    it "should return correct answer" do
      @question.randomised_answers.should include(@question.correct_answer)
    end

    it "should return the answers in a random order" do
      # Testing randomness is hard...
      random_answers = []
      10.times do
        random_answers << @question.randomised_answers
      end

      # All of our random sets of answers should contain the same questions.
      random_answers.each do |answer_set|
        answer_set.should =~ ["Wrong answer 1", "Wrong answer 2", "Correct answer"]
      end

      # If we uniq the random sets we should be left with more than one, as 
      # some of them should be sorted differently.
      random_answers.uniq.size.should_not == 1
    end
  end
end
