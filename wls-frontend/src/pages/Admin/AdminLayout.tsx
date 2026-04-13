import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import {
  FaBookOpen,
  FaBuilding,
  FaCogs,
  FaClipboardCheck,
  FaHome,
  FaShieldAlt,
  FaUsers,
} from "react-icons/fa";
import { useAuth } from "../../context/useAuth";
import "./Admin.css";

const navItems = [
  { to: "/admin", label: "Dashboard", icon: <FaHome /> },
  { to: "/admin/users", label: "Users", icon: <FaUsers /> },
  { to: "/admin/enrollments", label: "Enrollments", icon: <FaBookOpen /> },
  { to: "/admin/privileges", label: "Privileges", icon: <FaShieldAlt /> },
  { to: "/admin/hierarchy", label: "Hierarchy", icon: <FaBuilding /> },
  { to: "/admin/content", label: "Content", icon: <FaClipboardCheck /> },
  { to: "/admin/system", label: "System", icon: <FaCogs /> },
];

export default function AdminLayout() {
  const { logout } = useAuth();
  const navigate = useNavigate();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const onSignOut = async () => {
    setIsSidebarOpen(false);
    await logout();
    navigate("/");
  };

  const closeSidebar = () => setIsSidebarOpen(false);

  return (
    <div className="admin-shell">
      <div
        className={`admin-sidebar-backdrop ${isSidebarOpen ? "open" : ""}`}
        onClick={closeSidebar}
        aria-hidden="true"
      />

      <aside className={`admin-sidebar ${isSidebarOpen ? "open" : ""}`}>
        <div className="admin-sidebar-main">
          <div className="admin-sidebar-header">
            <div className="admin-brand">WLS Admin</div>
            <button
              type="button"
              className="admin-sidebar-close"
              onClick={closeSidebar}
              aria-label="Close admin menu"
            >
              Close
            </button>
          </div>

          <nav className="admin-nav">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === "/admin"}
                className={({ isActive }) => `admin-link${isActive ? " active" : ""}`}
                onClick={closeSidebar}
              >
                {item.icon}
                <span>{item.label}</span>
              </NavLink>
            ))}
          </nav>
        </div>

        <button type="button" className="admin-btn secondary admin-signout-btn" onClick={onSignOut}>
          Sign Out
        </button>
      </aside>

      <div className="admin-content" onClick={closeSidebar}>
        <header className="admin-mobile-header" onClick={(event) => event.stopPropagation()}>
          <button
            type="button"
            className="admin-sidebar-toggle"
            onClick={() => setIsSidebarOpen(true)}
            aria-label="Open admin menu"
          >
            Menu
          </button>
          <span className="admin-mobile-title">Admin</span>
        </header>

        <main className="admin-main" onClick={(event) => event.stopPropagation()}>
          <Outlet />
        </main>
      </div>
    </div>
  );
}
