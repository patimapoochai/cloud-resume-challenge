import React from 'react';
import styles from "./page.module.css";

import Footer from './components/footer';

const SectionItem = ({ title, date, children }) => {
  return (
    <div className={styles.sectionItem}
      style={date && { display: 'grid', gridTemplateColumns: 'repeat(2,1fr)' }}>
      <h2>{title}</h2>
      {date && <p style={{ fontSize: '1.5rem', fontWeight: 'bold', textAlign: 'right' }}>{date}</p>}
      {children}
    </div>
  );
}

const Section = ({ title, children }) => (
  <section className={styles.section}>
    <h1 className={styles.sectionHeader}>{title}</h1>
    {children}
  </section>
);

export default function Home() {
  return (
    <>
      <main className={styles.container}>
        <header className={styles.header}>
          <h1>Patima Poochai</h1>
          <p className={styles.headerSubtitle}>Lihue, HI 96766
            | patimap (at) protonmail.com
            | <a href="http://www.linkedin.com/in/patima-poochai808">Linkedin</a>
          </p>
        </header>
        <Section title="Accomplishments">
          <SectionItem title="Linux administration">
            <ul className={styles.ul}>
              <li>Installed and configured 3 clustered Linux virtualization servers and 1 pfSense router.
                Created virtual machine images and provisioned virtual machines.</li>
              <li>Competed in a 48-hour IT administration and incident response competition as an administrator
                overseeing 5 Linux servers. Maintained IT policy compliance by identifying and removing unauthorized programs and patching Linux services and user applications.</li>
            </ul>
          </SectionItem>
          <SectionItem title="Network administration">
            <ul className={styles.ul}>
              <li>Set up the networking infrastructure for an IT administration lab serving 15 students by
                configuring OpenVPN for remote access, managing remote access credentials, and
                troubleshooting user access issues.</li>
            </ul>
          </SectionItem>
          <SectionItem title="Teamwork and collaboration">
            <ul className={styles.ul}>
              <li>Coordinated the daily operations of a student club educating over 100 registered members on
                cybersecurity topics by planning club logistics and coordinating with 5 board members to
                facilitate events.</li>
            </ul>
          </SectionItem>
          <SectionItem title="Desktop Support">
            <ul className={styles.ul}>
              <li>Deployed over 300 windows computers using Active directory and MECM. Exceeded the target
                goal by 40 computers.</li>
            </ul>
          </SectionItem>
        </Section>
        <Section title="Work History">
          <SectionItem title="TEKsystems" date="Aug 2023 - Present">
            <p>Desktop Technician</p>
          </SectionItem>
          <SectionItem title="US Air Force & University of Hawaii at Manoa" date="Aug 2022 - Dec 2022">
            <p>Technical Lead</p>
          </SectionItem>
        </Section>
        <Section title="Certifications">
          <ul className={styles.ul}>
            <li><a href="https://rhtapps.redhat.com/verify?certId=240-145-797">Red Hat Certified System Administrator</a></li>
            <li><a href="https://www.credly.com/badges/674b29e8-c49a-41bb-99c7-e35518cf4c50/public_url">CompTIA Security+</a></li>
            <li><a href="https://www.credly.com/badges/bae02fcc-35bf-4911-a878-56dcefc812cd/public_url">CompTIA Network+</a></li>
            <li><a href="https://cp.certmetrics.com/amazon/en/public/verify/credential/d578d3caf2374818b395da7d4cc5b759">AWS Certified Cloud Practitioner</a></li>
          </ul>
        </Section>
        <Section title="Education">
          <SectionItem title="B.A. Information and Computer Science" date="2018 - 2022">
            <p>University of Hawaii at Manoa, HI</p>
          </SectionItem>
        </Section>
      </main>
      <Footer />
    </>
  );
}
