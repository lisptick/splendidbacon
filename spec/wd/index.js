describe('Splendid beacon tour', function() {
    var client;
    before(function (done) {
        client = newClient();
        require('webdrivercss').init(client);
        client
            .url('http://localhost:1337')
            .call(done);
    });

    after(function (done) {
        client.end(done);
    });

    it('should display homepage', function(done) {
        client
            .waitForExist('#frontpage')
            .screentest('homepage')
            .call(done);
    });

    it('should be possible to sign in', function(done) {
        client
            .click('a[href="/users/sign_in"]')
            .waitForExist('#user_email')
            .screentest('signin')
            .setValue('#user_email', 'foo@baz.ext')
            .setValue('#user_password', 'password')
            .submitForm('#new_user')
            .call(done);
    });

    it('should start on dashboard', function(done) {
        client
            .waitForExist('a.dashboard', 1000)
            .screentest('dashboard')
            .call(done);
    });

    it('should display timeline', function(done) {
        client
            .click('a[href*="timeline"]')
            .waitForExist('#timeline', 1000)
            .screentest('timeline')
            .call(done);
    });

    it('should display new project form', function(done) {
        client
            .click('a[href="/projects/new"]')
            .waitForExist('#new_project')
            .screentest('project create')
            .call(done);
    });

    it('should be possible to create a new project', function(done) {
        client
            .setValue('#project_name', 'Test project')
            .setValue('#project_human_start', '15 September 2014')
            .setValue('#project_human_end', '30 September 2014')
            .submitForm('#new_project')
            .call(done);
    });

    it('should display project edit form', function(done) {
        client
            .waitForExist('a.button.edit[href^="/projects"]')
            .click('a.button.edit[href^="/projects"]')
            .waitForExist('input[value="Destroy this project!"]', 1000)
            .screentest('project edit')
            .call(done);
    });

    it('should be possible to create a new project', function(done) {
        client
            .click('input[value="Destroy this project!"]')
            .alertAccept()
            .waitForExist('#dashboard')
            .call(done);
    });

    it('should display profile edit', function(done) {
        client
            .click('a[href="/users/edit"]')
            .waitForExist('#edit_user')
            .screentest('account edit')
            .call(done);
    });

    it('should log out', function(done) {
        client
            .click('a[href="/users/sign_out"]')
            .waitForExist('#new_user')
            .call(done);
    });
});
