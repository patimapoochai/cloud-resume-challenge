describe('E2E website', () => {
  const apiUrl = "https://optv3pe2ce.execute-api.us-east-1.amazonaws.com/default/lambda-tutorial";
  it('loads', () => {
    // cy.visit('https://resume.patimapoochai.net');
    cy.visit('http://localhost:3000');
    cy.contains('Patima Poochai');
  })

  it('can get visitor from API', () => {
    cy.visit('http://localhost:3000');
    cy.request("POST",
      apiUrl)
      .then(res => {
        expect(res.status).to.eq(200);
        expect(res.body).to.be.a('object');
      })
  })

  it('increments the visitor count each visit', () => {
    let visitorCount;
    cy.visit('http://localhost:3000');

    cy.request("POST",
      apiUrl)
      .then(res => {
        visitorCount = +res.body.VisitorCount;
      });

    cy.request("POST",
      apiUrl)
      .then(res => {
        // console.log(visitorCount + " vs " + res.body.VisitorCount);
        expect(res.body.VisitorCount > visitorCount, 'Visitor count isn\'t more than previous value')
          .to.eq(true);
      });
  })

  it('remembers your IP address', () => {
    let uniqueVisitorCount;
    cy.visit('http://localhost:3000');

    cy.request("POST",
      apiUrl,
      { "queryType": "unique" }
    )
      .then(res => {
        console.log(res);
        uniqueVisitorCount = +res.body.UniqueVisitors;
      });

    cy.request("POST",
      apiUrl,
      { "queryType": "unique" }
    )
      .then(res => {
        expect(res.body.UniqueVisitors == uniqueVisitorCount, 'Visitor count isn\'t more than previous value')
          .to.eq(true);
      });
  })

  it('rejects malformed POST requests', () => {
    cy.visit('http://localhost:3000');

    cy.request({
      method: 'POST',
      url: apiUrl,
      body: { "queryType": "uniq" },
      failOnStatusCode: false,
    }).then(res => {
      expect(res.status).to.be.gt(399);
    })

    cy.request({
      method: 'POST',
      url: apiUrl,
      body: { "querType": "unique" },
      failOnStatusCode: false,
    }).then(res => {
      expect(res.status).to.be.gt(399);
    })

    cy.request({
      method: 'POST',
      url: apiUrl,
      body: "bad",
      failOnStatusCode: false,
    }).then(res => {
      expect(res.status).to.be.gt(399);
    })
  })
})
