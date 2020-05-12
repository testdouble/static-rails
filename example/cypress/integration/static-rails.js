
describe('rails-static stuff seems to work', () => {
  it('accesses the 11ty site at blog.localhost/docs', () => {
    cy.visit(`http://blog.localhost:3009/docs`)
    cy.get('p').should('have.text', 'Hi')

    cy.visit(`http://blog.localhost:3009/docs/index.html`)
    cy.get('p').should('have.text', 'Hi')
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
})
