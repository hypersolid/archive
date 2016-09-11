describe("Cell", function() {
  var Cell = require('../../lib/Cell');
  var Colony = require('../../lib/Colony');
  var cell;

  beforeEach(function() {
    cell = new Cell(0, 0);
  });

  it("should be aware of its neighbours", function() {
    expect(cell.adjustent(new Cell(0,1))).toEqual(true);
    expect(cell.adjustent(new Cell(0,-1))).toEqual(true);
    expect(cell.adjustent(new Cell(1,0))).toEqual(true);
    expect(cell.adjustent(new Cell(-1,0))).toEqual(true);
    expect(cell.adjustent(new Cell(1,1))).toEqual(true);
    expect(cell.adjustent(new Cell(-1,-1))).toEqual(true);
    expect(cell.adjustent(new Cell(1,-1))).toEqual(true);
    expect(cell.adjustent(new Cell(-1,1))).toEqual(true);
  });

  it("should be aware of its neighbours's neighbours", function() {
    expect(cell.adjustent(new Cell(0,2))).toEqual(true);
    expect(cell.adjustent(new Cell(0,-2))).toEqual(true);
    expect(cell.adjustent(new Cell(2,0))).toEqual(true);
    expect(cell.adjustent(new Cell(-2,0))).toEqual(true);
    expect(cell.adjustent(new Cell(2,2))).toEqual(true);
    expect(cell.adjustent(new Cell(-2,-2))).toEqual(true);
    expect(cell.adjustent(new Cell(2,-2))).toEqual(true);
    expect(cell.adjustent(new Cell(-2,2))).toEqual(true);
  });

  it("should NOT be aware of its neighbours's neighbours's neighbours", function() {
    expect(cell.adjustent(new Cell(0,3))).toEqual(false);
    expect(cell.adjustent(new Cell(0,-3))).toEqual(false);
    expect(cell.adjustent(new Cell(3,0))).toEqual(false);
    expect(cell.adjustent(new Cell(-3,0))).toEqual(false);
    expect(cell.adjustent(new Cell(3,3))).toEqual(false);
    expect(cell.adjustent(new Cell(-3,-3))).toEqual(false);
    expect(cell.adjustent(new Cell(3,-3))).toEqual(false);
    expect(cell.adjustent(new Cell(-3,3))).toEqual(false);
  });

  it("should be aware of (omg!) clones", function() {
    expect(cell.equal(new Cell(0,0))).toEqual(true);
  });

  it("should live or die (underpopulation)", function() {
    var colony = new Colony([new Cell(10,0), new Cell(0,1)]);
    expect(cell.liveOrDie(colony)).toEqual(false);
  });

  it("should live or die (normal)", function() {
    var colony = new Colony([new Cell(1,0), new Cell(0,1)]);
    expect(cell.liveOrDie(colony)).toEqual(true);
  });

  it("should live or die (reproduction)", function() {
    var colony = new Colony([new Cell(1,1), new Cell(1,0), new Cell(0,1)]);
    expect(cell.liveOrDie(colony)).toEqual(true);
  });

  it("should live or die (overpopulation)", function() {
    var colony = new Colony([new Cell(1,1), new Cell(1,0), new Cell(0,1), new Cell(-1, -1)]);
    expect(cell.liveOrDie(colony)).toEqual(false);
  });
});
