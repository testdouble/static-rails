
describe('rails-static stuff seems to work', () => {
  it('accesses the 11ty site at blog.localhost/docs', () => {
    // Make sure the literal index HTML file works
    cy.visit(`http://blog.localhost:3009/docs/index.html`)
    cy.get('p').should('have.text', 'Hi')

    // Also make sure hitting the directory without trailing / works
    cy.visit(`http://blog.localhost:3009/docs`)
    cy.get('p').should('have.text', 'Hi')
    cy.get('#api-result').should('contain.text', 'API liked our CSRF token and sent back ID: 22')
  })

  it('accesses the hugo site at blog.localhost', () => {
    cy.visit('http://blog.localhost:3009')

    cy.get('header a')
      .should('contain.text', 'My Blerg')
      .should('have.attr', 'href', '/')

    cy.contains('My First Post').click()
    cy.get('article').should('contain.text', 'I am a post')
  })

  it('accesses the jekyll site at /docs', () => {
    cy.visit('http://localhost:3009/docs')

    cy.get('.post-link').click()
    cy.get('.post-content').should('contain.text', 'find this post in your')
  })

  it('accesses the hugo site at /marketing', () => {
    cy.visit('http://localhost:3009/marketing')

    cy.get('header a')
      .should('contain.text', 'My Marketing Page')
      .should('have.attr', 'href', '/marketing/')

    cy.contains('My First Post').click()
    cy.get('article').should('contain.text', 'I am a post')
  })

  it('can access an API carved out within where the 11ty site is mounted', () => {
    cy.visit('http://blog.localhost:3009/docs')
    cy.getCookie('_csrf_token').then((cookie) => {
      cy.request({
        url: 'http://blog.localhost:3009/docs/api/houses',
        method: 'POST',
        headers: {
          'x-csrf-token': decodeURIComponent(cookie.value)
        }
      }).then((res) => {
        cy.request(`http://blog.localhost:3009/docs/api/houses/${res.body.id}`).should((response) => {
          expect(response.status).to.eq(200)
          expect(response.body).to.have.property('id', 22)
          expect(response.body).to.have.property('fake', true)
        })
      })
    })
  })

  it('[Production only] assign better cache-control for images', () => {
    if (Cypress.env('RAILS_ENV') !== 'production') return

    cy.request('http://localhost:3009/docs/assets/an_image.png').should((response) => {
      expect(response.headers).to.include({
        'cache-control': 'public; max-age=31536000',
        'content-length': '4320',
        'content-type': 'image/png'
      })

      const lastModified = response.headers['last-modified']
      expect(lastModified).not.to.be.empty

      const preModified = new Date(new Date(lastModified).getTime() - 10000).toUTCString()
      cy.request({
        url: 'http://localhost:3009/docs/assets/an_image.png',
        headers: {
          'if-modified-since': preModified
        }
      }).should((response) => {
        expect(response.status).to.eq(200)
      })

      const postModified = new Date(new Date(lastModified).getTime() + 10000).toUTCString()
      cy.request({
        url: 'http://localhost:3009/docs/assets/an_image.png',
        headers: {
          'if-modified-since': postModified
        }
      }).should((response) => {
        expect(response.status).to.eq(304)
      })
    })
  })

  it('[Production only] cache-control no cache for HTML', () => {
    if (Cypress.env('RAILS_ENV') !== 'production') return

    cy.request('http://blog.localhost:3009/docs/index.html').should((response) => {
      expect(response.headers).to.include({
        'cache-control': 'no-cache, no-store',
        // 'content-length': '4320',
        'content-type': 'text/html'
      })
    })
  })

  it('[Production only] gzips most file types', () => {
    if (Cypress.env('RAILS_ENV') !== 'production') return

    cy.request({
      url: 'http://localhost:3009/docs/assets/a_javascript.js',
      headers: {
        'accept-encoding': 'gzip'
      }
    }).should(response => {
      expect(response.headers).to.include({
        'vary': 'Accept-Encoding',
        'content-encoding': 'gzip',
        'content-length': '58',
        'content-type': 'application/javascript'
      })
    })

    cy.request({
      url: 'http://localhost:3009/docs/assets/a_json.json',
      headers: {
        'accept-encoding': 'gzip'
      }
    }).should(response => {
      expect(response.headers).to.include({
        'vary': 'Accept-Encoding',
        'content-encoding': 'gzip',
        'content-length': '58',
        'content-type': 'application/json'
      })
    })

    cy.request({
      url: 'http://localhost:3009/docs/assets/a_css.css',
      headers: {
        'accept-encoding': 'gzip'
      }
    }).should(response => {
      expect(response.headers).to.include({
        'vary': 'Accept-Encoding',
        'content-encoding': 'gzip',
        'content-type': 'text/css'
      })
    })

    cy.request({
      url: 'http://localhost:3009/docs/assets/a_html.html',
      headers: {
        'accept-encoding': 'gzip'
      }
    }).should(response => {
      expect(response.headers).to.include({
        'vary': 'Accept-Encoding',
        'content-encoding': 'gzip',
        'content-type': 'text/html'
      })
    })

    cy.request({
      url: 'http://localhost:3009/docs/assets/an_image.png',
      headers: {
        'accept-encoding': 'gzip'
      }
    }).should(response => {
      expect(response.headers['content-encoding']).to.be.undefined
      expect(response.headers['vary']).to.be.undefined
      expect(response.headers).to.include({
        'content-type': 'image/png'
      })
    })
  })

  it('[Production only] will serve up 404 pages with 404 status code', () => {
    if (Cypress.env('RAILS_ENV') !== 'production') return
    cy.visit('http://localhost:3009/marketing/fooberry', {
      failOnStatusCode: false
    })

    cy.contains('I am a 404 page for /marketing')

    cy.request({
      url: 'http://localhost:3009/marketing/lmao',
      failOnStatusCode: false
    }).should(res => {
      expect(res.status).to.eq(404)
    })
  })


})
