describe User do

  let!(:user) do
    User.create(email: 'test@test.com', password: 'secret1234',
               password_confirmation: 'secret1234')
  end

  it 'authenticate when given a valid email address and password' do
    authenticated_user = User.authenticate(user.email, user.password)
    expect(authenticated_user).to eq user
  end

  it 'does not authenticate when given an in password' do
    expect(User.authenticate(user.email, 'wrong_stupid_')).to be_nil
  end

end
