function getFirstWord(textString) {
  return textString.split(" ")[0];
}

describe('E2E website', () => {
  const websiteUrl = 'https://resume.patimapoochai.net'
  const apiUrl = "https://resumeapi.patimapoochai.net/visitor";
  // cy.visit('https://resume.patimapoochai.net');
  it('loads and contain resume elements', () => {
    cy.visit(websiteUrl);
    cy.contains('Patima Poochai');
    cy.contains('TEKsystems');
    cy.contains('University of Hawaii at Manoa');
  })

  // it displays visitors as numbers
  it('displays a number with the regular visitor count', () => {
    cy.visit(websiteUrl);
    //cy.get('p').contains('visitors (page views)').should('not.have.value', 'undefined')
    cy.get('p', { timeout: 10000 }).contains('visitors (page views)').then(($object) => {
      const firstWord = getFirstWord($object.text());
      expect(Number.isInteger(parseInt(firstWord))).to.be.true;
    })
  })

  it('displays a number with the unique visitor count', () => {
    cy.visit(websiteUrl);
    cy.get('p', { timeout: 10000 }).contains('unique visitors').then(($object) => {
      const firstWord = getFirstWord($object.text());
      expect(Number.isInteger(parseInt(firstWord))).to.be.true;
    })
  })

  it('increments the regular visitor count each visit', () => {
    cy.visit(websiteUrl);
    cy.get('p', { timeout: 10000 }).contains('visitors (page views)').then(($object) => {
      const firstCount = parseInt(getFirstWord($object.text()));
      cy.visit(websiteUrl);
      cy.get('p').contains('visitors (page views)').then(($object) => {
        const secondCount = parseInt(getFirstWord($object.text()));
        expect(secondCount > firstCount, "regular visitor count after reloading must be more than before")
          .to.be.true;
      })
    })
  })

  it('remembers your IP address', () => {
    cy.visit(websiteUrl);
    cy.get('p').contains('unique visitors').then(($object) => {
      const firstCount = parseInt(getFirstWord($object.text()));
      cy.visit(websiteUrl);
      cy.get('p').contains('unique visitors').then(($object) => {
        const secondCount = parseInt(getFirstWord($object.text()));
        console.log(firstCount);
        console.log(secondCount);
        expect(secondCount == firstCount, "regular visitor count after reloading must be equal to previous value")
          .to.be.true;
      })
    })
  })
})
