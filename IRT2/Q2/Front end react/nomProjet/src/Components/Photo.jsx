function Photo({ id, author, size, url, showId }) {
  return (
    <div>
        <h3>{author} {showId && id}</h3>
        <a href={url}>
            <img id={id} src={url} alt="photo" style={{
                width: size.width, 
                height: size.height, 
                padding: '10px'
            }}/>
        </a>
    </div>
  )
}

export default Photo;