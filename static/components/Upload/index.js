import React from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import { withStyles } from "@material-ui/core/styles";
import "bootstrap/dist/css/bootstrap.min.css";
import Table from "../Table";
import ButtonBase from "@material-ui/core/ButtonBase";
import Typography from "@material-ui/core/Typography";
import axios from "../../axios";

const images = [
  {
    url: "/static/imgs/2.jpg",
    title: "Rose",
    width: "33.333333333%",
  },
  {
    url: "/static/imgs/1.jpg",
    title: "Daisy",
    width: "33.333333333%",
  },
  {
    url: "/static/imgs/3.jpg",
    title: "Sunflower",
    width: "33.3333333333%",
  },
  {
    url: "/static/imgs/4.jpeg",
    title: "Dandelion",
    width: "33.333333333%",
  },
  {
    url: "/static/imgs/5.jpg",
    title: "Tulip",
    width: "33.333333333%",
  },
  {
    url: "/static/imgs/6.jpg",
    title: "Dandelion (v2)",
    width: "33.333333333%",
  },
];

const useStyles = (theme) => ({
  root: {
    "& > *": {
      margin: theme.spacing(1),
    },
  },
  input: {
    display: "none",
  },
  button: {
    borderRadius: 3,
    border: 0,
    color: "white",
    height: 48,
    padding: "0 60px",
  },
  image: {
    "&:hover, &$focusVisible": {
      zIndex: 1,
      "& $imageBackdrop": {
        opacity: 0.15,
      },
      "& $imageMarked": {
        opacity: 0,
      },
      "& $imageTitle": {
        border: "4px solid currentColor",
      },
    },
  },
  focusVisible: {},

  rootGallery: {
    display: "flex",
    flexWrap: "wrap",
    minWidth: 300,
    width: "100%",
  },
  imageGallery: {
    position: "relative",
    height: 200,
    [theme.breakpoints.down("xs")]: {
      width: "100% !important", // Overrides inline-style
      height: 100,
    },
    "&:hover, &$focusVisible": {
      zIndex: 1,
      "& $imageBackdrop": {
        opacity: 0.15,
      },
      "& $imageMarked": {
        opacity: 0,
      },
      "& $imageTitle": {
        border: "4px solid currentColor",
      },
    },
  },

  imageButton: {
    position: "absolute",
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    color: theme.palette.common.white,
  },
  imageSrc: {
    position: "absolute",
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    backgroundSize: "cover",
    backgroundPosition: "center 40%",
  },
  imageBackdrop: {
    position: "absolute",
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    backgroundColor: theme.palette.common.black,
    opacity: 0.4,
    transition: theme.transitions.create("opacity"),
  },
  imageTitle: {
    position: "relative",
    padding: `${theme.spacing(2)}px ${theme.spacing(4)}px ${
      theme.spacing(1) + 6
    }px`,
  },
  imageMarked: {
    height: 3,
    width: 18,
    backgroundColor: theme.palette.common.white,
    position: "absolute",
    bottom: -2,
    left: "calc(50% - 9px)",
    transition: theme.transitions.create("opacity"),
  },
  wrapper: {
    height: 100,
    border: "none",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  },
});

class Upload extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      file: null,
      predictions: null,
    };
    this.handleChange = this.handleChange.bind(this);
  }

  sendImage(image) {
    const config = {
      headers: { "content-type": "multipart/form-data" },
    };
    const data = new FormData();
    data.append("file", image);
    data.append("filename", image.name);
    axios
      .post(`http://localhost:5000/api/predictions`, data, config)
      .then((res) => {
        this.setState({
          predictions: res.data,
        });
      });
  }

  handleChange(event) {
    this.setState({
      file: URL.createObjectURL(event.target.files[0]),
    });
    this.sendImage(event.target.files[0]);
  }

  async loadThumbnail(src) {
    this.setState({
      file: src,
    });

    let response = await fetch("http://localhost:5000" + src);
    let data = await response.blob();
    let metadata = {
      type: "image/jpeg",
    };
    let file = new File([data], "test.jpg", metadata);

    this.sendImage(file);
  }

  render() {
    const { classes } = this.props;

    return (
      <div className="container">
        <h1 style={{ textAlign: "center", paddingBottom: 30, paddingTop: 30 }}>
          Demo
        </h1>

        <div className="row">
          <div className="col-sm-6">
            <h2 style={{ textAlign: "center" }}>Upload your photo</h2>

            <img
              className="img-fluid"
              src={this.state.file}
              style={{ paddingTop: 20, maxHeight: 500 }}
            />
            <div className={classes.root} style={{ paddingTop: 20 }}>
              <input
                accept="image/*"
                className={classes.input}
                id="contained-button-file"
                multiple
                type="file"
                onChange={this.handleChange}
              />
              <div className={classes.wrapper}>
                <label htmlFor="contained-button-file">
                  <Button
                    className={classes.button}
                    variant="contained"
                    color="primary"
                    component="span"
                  >
                    Upload
                  </Button>
                </label>
              </div>
            </div>
          </div>
          <div className="col-sm-6">
            {this.state.predictions != null ? (
              <div style={{ paddingBottom: 20 }}>
                <h2 style={{ textAlign: "center" }}>Predictions</h2>

                <div style={{ paddingTop: 20 }}> </div>
                <Table predictions={this.state.predictions} />
              </div>
            ) : null}
            <h2 style={{ paddingBottom: 20, textAlign: "center" }}>
              Try with example images
            </h2>
            <div className={classes.rootGallery}>
              {images.map((image) => (
                <ButtonBase
                  focusRipple
                  key={image.title}
                  className={classes.imageGallery}
                  focusVisibleClassName={classes.focusVisible}
                  style={{
                    width: image.width,
                  }}
                  onClick={() => this.loadThumbnail(image.url)}
                >
                  <span
                    className={classes.imageSrc}
                    style={{
                      backgroundImage: `url(${image.url})`,
                    }}
                  />
                  <span className={classes.imageBackdrop} />
                  <span className={classes.imageButton}>
                    <Typography
                      component="span"
                      variant="subtitle1"
                      color="inherit"
                      className={classes.imageTitle}
                    >
                      {image.title}
                      <span className={classes.imageMarked} />
                    </Typography>
                  </span>
                </ButtonBase>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

Upload.propTypes = {
  classes: PropTypes.object.isRequired,
};

export default withStyles(useStyles)(Upload);
