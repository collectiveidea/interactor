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
      let(:interactor) { AuthenticateUser.new(email: "john@example.com", password: "secret") }
      let(:context) { interactor.context }

      context "when given valid credentials" do
        let(:user) { double(:user, secret_token: "token") }

        before do
          allow(User).to receive(:authenticate).with("john@example.com", "secret").and_return(user)
        end

        it "succeeds" do
          interactor.call

          expect(context).to be_a_success
        end

        it "provides the user" do
          expect {
            interactor.call
          }.to change {
            context.user
          }.from(nil).to(user)
        end

        it "provides the user's secret token" do
          expect {
            interactor.call
          }.to change {
            context.token
          }.from(nil).to("token")
        end
      end

      context "when given invalid credentials" do
        before do
          allow(User).to receive(:authenticate).with("john@example.com", "secret").and_return(nil)
        end

        it "fails" do
          interactor.call

          expect(context).to be_a_failure
        end

        it "provides a failure message" do
          expect {
            interactor.call
          }.to change {
            context.message
          }.from(nil).to be_present
        end
      end
    end
  end
end
