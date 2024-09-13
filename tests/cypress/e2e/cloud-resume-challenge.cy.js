describe('E2E website', () => {
  it('loads', () => {
    // cy.visit('https://resume.patimapoochai.net');
    cy.visit('http://localhost:3000');
    cy.contains('Patima Poochai');
  })

  it('can get visitor from API', () => {
    cy.visit('http://localhost:3000');
    cy.request("POST",
      'https://optv3pe2ce.execute-api.us-east-1.amazonaws.com/default/lambda-tutorial')
      .then(res => {
        expect(res.status).to.eq(200);
        expect(res.body).to.be.a('object');
      })
  })

  it('increments the visitor count each visit', () => {
    let visitorCount;
    cy.visit('http://localhost:3000');

    cy.request("POST",
      'https://optv3pe2ce.execute-api.us-east-1.amazonaws.com/default/lambda-tutorial')
      .then(res => {
        visitorCount = +res.body.VisitorCount;
      });

    cy.request("POST",
      'https://optv3pe2ce.execute-api.us-east-1.amazonaws.com/default/lambda-tutorial')
      .then(res => {
        // console.log(visitorCount + " vs " + res.body.VisitorCount);
        expect(res.body.VisitorCount > visitorCount, 'Visitor count isn\'t more than previous value')
          .to.eq(true);
      });
  })
})
