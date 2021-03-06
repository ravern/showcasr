import React, {Component} from 'react';

import firebase from 'firebase/app';

import './Login.css';

class Login extends Component {
  constructor(props) {
    super(props);

    this.state = {
      error: null,
      form: {
        email: '',
        password: '',
      },
    };

    this.onEmailInputChanged = this.onEmailInputChanged.bind(this);
    this.onPasswordInputChanged = this.onPasswordInputChanged.bind(this);
    this.onSubmitButtonPressed = this.onSubmitButtonPressed.bind(this);

    this.renderError = this.renderError.bind(this);
  }

  onEmailInputChanged(event) {
    const form = this.state.form;
    form.email = event.target.value;
    this.setState({form});
  }

  onPasswordInputChanged(event) {
    const form = this.state.form;
    form.password = event.target.value;
    this.setState({form});
  }

  onSubmitButtonPressed(event) {
    event.preventDefault();

    firebase
      .auth()
      .signInWithEmailAndPassword(
        this.state.form.email,
        this.state.form.password,
      )
      .then(console.log)
      .catch(error => {
        this.setState({error: error.message});
      });
  }

  render() {
    return (
      <div className="Login-main">
        <h2>Showcasr</h2>
        <form className="Login-form" onSubmit={this.onSubmitButtonPressed}>
          <div className="Login-form-group">
            <input
              type="text"
              value={this.state.form.email}
              onChange={this.onEmailInputChanged}
              placeholder="Email"
              name="email"
            />
          </div>
          <div className="Login-form-group">
            <input
              type="password"
              value={this.state.form.password}
              onChange={this.onPasswordInputChanged}
              placeholder="Password"
              name="password"
            />
          </div>
          <div className="Login-form-group">
            <button className="Login-form-submit-button" type="submit">
              Login
            </button>
          </div>
        </form>
        {this.state.error ? this.renderError() : null}
      </div>
    );
  }

  renderError() {
    return (
      <div className="Login-error">
        <p>{this.state.error}</p>
      </div>
    );
  }
}

export default Login;
