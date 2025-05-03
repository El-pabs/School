import { Link } from "react-router-dom";

function NotFound() {
  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>404 - Page non trouvée</h1>
      <p>La page que vous recherchez n'existe pas.</p>
      <Link to="/" style={{ color: "blue", textDecoration: "underline" }}>
        Cliquez sur ce lien
      </Link> pour revenir à la page d'accueil.
    </div>
  );
}

export default NotFound;