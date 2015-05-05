class AuthenticateUser
  include Interactor

  def call
    if user = User.authenticate(context.email, context.password)
      context.user = user
      context.token = user.secret_token
    else
      context.fail!(message: "authenticate_user.failure")
    end
  end
end

class User; end

describe "The testing example from the README" do
  describe AuthenticateUser do
    describe "#call" do
      subject(:context) { AuthenticateUser.call(email: "john@example.com", password: "secret") }

      context "when given valid credentials" do
        let(:user) { double(:user, secret_token: "token") }

        before do
          allow(User).to receive(:authenticate).with("john@example.com", "secret").and_return(user)
        end

        it { is_expected.to be_a_success }

        it "provides the user" do
          expect(subject.user).to eq(user)
        end

        it "provides the user's secret token" do
          expect(subject.token).to eq("token")
        end
      end

      context "when given invalid credentials" do
        before do
          allow(User).to receive(:authenticate).with("john@example.com", "secret").and_return(nil)
        end

        it { is_expected.to be_a_failure }

        it "provides a failure message" do
          expect(subject.message).to_not be_nil  # be_present requires activesupport
        end
      end
    end
  end
end
