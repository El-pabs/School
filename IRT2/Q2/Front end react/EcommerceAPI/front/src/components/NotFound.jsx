import { Link } from "react-router-dom";

function NotFound() {
  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>404 - Page non trouvée</h1>
      <p>La page que vous recherchez n'existe pas.</p>
      <p>
        <Link to="/" style={{ color: "blue", textDecoration: "underline" }}>
          Cliquez ici pour revenir à la page d'accueil
        </Link>
      </p>
    </div>
  );
}

export default NotFound;