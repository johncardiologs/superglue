QUnit.module "Snapshot"

testWithSession "without transition cache", (assert) ->
  done = assert.async()
  load = 0
  restoreCalled = false
  @document.addEventListener 'relax:load', =>
    load += 1
    if load is 1
      assert.equal @document.title, 'title 2'
      setTimeout (=>
        @Relax.visit('/app/session')), 0
    else if load is 2
      assert.notOk restoreCalled
      assert.equal @document.title, 'title'
      location = @window.location
      state = relax: true, url: "#{location.protocol}//#{location.host}/app/session"
      assert.propEqual @history.state, state
      done()
  @document.addEventListener 'relax:restore', =>
    restoreCalled = true
  @Relax.visit('/app/success')

testWithSession "with same URL, skips transition cache", (assert) ->
  done = assert.async()
  restoreCalled = false
  @document.addEventListener 'relax:restore', =>
    restoreCalled = true
  @document.addEventListener 'relax:load', =>
    assert.notOk restoreCalled
    done()
  @Relax.enableTransitionCache()
  @Relax.visit('/app/session')

testWithSession "transition cache can be disabled with an override", (assert) ->
  done = assert.async()
  restoreCalled = false
  @document.addEventListener 'relax:restore', =>
    restoreCalled = true
  @document.addEventListener 'relax:load', =>
    assert.notOk restoreCalled
    done()
  @Relax.enableTransitionCache()
  @Relax.visit('/app/success_with_transition_cache_override')


testWithSession "history.back() will use the cache if avail", (assert) ->
  done = assert.async()
  change = 0
  fetchCalled = false
  @document.addEventListener 'relax:load', =>
    change += 1
    if change is 1
      @document.addEventListener 'relax:request-start', -> fetchCalled = true
      assert.equal @document.title, 'title 2'
      setTimeout =>
        @history.back()
      , 0
    else if change is 2
      assert.notOk fetchCalled
      assert.equal @document.title, 'title'
      done()
  @Relax.visit('/app/success')

testWithSession "history.back() will miss the cache if there's no cache", (assert) ->
  done = assert.async()
  change = 0
  restoreCalled = false

  @document.addEventListener 'relax:restore', =>
    restoreCalled = true

  @document.addEventListener 'relax:load', =>
    change += 1
    if change is 1
      assert.equal @document.title, 'title 2'
      setTimeout =>
        @history.back()
      , 0
    else if change is 2
      assert.equal @document.title, 'title'
      assert.equal restoreCalled, false
      done()
  @Relax.pagesCached(0)
  @Relax.visit('/app/success')