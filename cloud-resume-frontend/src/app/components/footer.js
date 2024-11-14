'use client';
import { useState, useEffect } from 'react';
import styles from "./footer.module.css";

export default function Footer() {
  const [views, setViews] = useState(null);
  const [uniqueViews, setUniqueViews] = useState(null);
  const apiUrl = 'https://resumeapi.patimapoochai.net/visitor';
  const projectUrl = 'https://github.com/patimapoochai/cloud-resume-challenge';

  useEffect(() => {
    fetch(apiUrl, {
      method: "POST",  // this part is where the server is missing CORS Access-Control-Allow-Origin
    })
      .then(res => {
        if (res.ok)
          return res.json();
      })
      .then(res => {
        setViews(res.VisitorCount);
      })
  }, []);

  useEffect(() => {
    fetch(apiUrl, {
      method: "POST",
      body: JSON.stringify({ queryType: "unique" }),
    })
      .then(res => {
        if (res.ok)
          return res.json();
      })
      .then(res => {
        setUniqueViews(res.VisitorCount);
      })
  }, []);

  return (
    <footer className={styles.footer}>
      <p>View project on <a href={projectUrl}>Github</a></p>
      <p>{views ? `${views} visitors (page views)` : "loading visitors"}</p>
      <p>{uniqueViews ? `${uniqueViews} unique visitors` : "loading visitors"}</p>
    </footer>
  );
}

