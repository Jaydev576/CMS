import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/useAuth";
import "../../App.css"; // Ensure styles are pulled in

export default function LoginPage() {
  const { login, isAuthenticating } = useAuth();
  const navigate = useNavigate();

  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [errorMsg, setErrorMsg] = useState("");

  const handleLogin = async () => {
    if (!username.trim() || !password.trim() || isAuthenticating) {
      return;
    }

    setErrorMsg("");
    try {
      const result = await login(username, password);
      navigate(result.roleId === 2 ? "/creator/dashboard" : "/subjects");
    } catch (err) {
      console.error("Login failed", err);
      setErrorMsg("Invalid username or password");
    }
  };

  return (
    <div className="login-wrapper">
      <div className="auth-card animate-fade-in">
        <div className="auth-header">
          <h2>Academic Portal</h2>
          <p>Sign in to access your dashboard</p>
        </div>

        {errorMsg && (
          <div style={{ color: 'var(--danger)', fontSize: '0.9rem', textAlign: 'center', backgroundColor: '#fee2e2', padding: '0.5rem', borderRadius: '4px' }}>
            {errorMsg}
          </div>
        )}

        <div className="input-group">
          <label className="input-label" htmlFor="username">Username</label>
          <input
            id="username"
            type="text"
            placeholder="Enter your username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleLogin()}
          />
        </div>

        <div className="input-group">
          <label className="input-label" htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            placeholder="Enter your password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleLogin()}
          />
        </div>

        <button className="btn-primary" onClick={handleLogin} disabled={isAuthenticating}>
          {isAuthenticating ? "Signing In..." : "Sign In"}
        </button>
      </div>
    </div>
  );
}
