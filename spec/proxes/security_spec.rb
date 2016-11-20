require 'spec_helper'
require 'proxes/security'
require 'rack'
require 'pundit/rspec'

describe ProxES::Security do
  def app
    ProxES::Security.new(proc{[200,{},['Hello, world.']]})
  end

  context '#call' do
    fit 'rejects anonymous requests' do
      expect { get('/') }.to raise_error(ProxES::Helpers::NotAuthenticated)
    end

    context 'logged in' do
      let(:user) { create(:user) }

      before(:each) do
        # Log in
        warden = double(Warden::Proxy)
        allow(warden).to receive(:user).and_return(user)
        allow(warden).to receive(:authenticate!)
        env 'warden', warden
      end

      it 'authorizes calls that return data' do
        expect(get("/#{user.email}/_search")).to be_ok
        expect{ get('/notmyindex/_search') }.to raise_error(Pundit::NotAuthorizedError)
      end

      it 'authorizes calls that do actions' do
      end
    end
  end
end