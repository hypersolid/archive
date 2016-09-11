var Cell = require('./Cell');

function Colony(cells) {
  this.cells = cells;
  this.rehashCells();
}

Colony.prototype.rehashCells = function() {
  this.cellsHash = {};

  for (i in this.cells) {
    this.cellsHash[this.cells[i].key()] = this.cells[i];
  }
}

Colony.prototype.unhashCells = function() {
  this.cells = [];

  for (key in this.cellsHash) {
    this.cells.push(this.cellsHash[key]);
  }
}

Colony.prototype.clearDeadCells = function() {
  for (key in this.cellsHash) {
    if (this.cellsHash[key].dead) {
      delete this.cellsHash[key];
    }
  }
}

Colony.prototype.liveOrDie = function() {
  for (var key in this.cellsHash) {
    if (!this.cellsHash[key].liveOrDie(this)) {
      this.cellsHash[key].dead = true;
    }
  }
}

Colony.prototype.thrive = function() {
  var new_cells = [];

  for (var key in this.cellsHash) {
    var cell = this.cellsHash[key];

    for (var p = -1; p < 2; p++) {
      for (var o = -1; o < 2; o++) {
        if (p != 0 || o != 0) {
          candidate = new Cell(cell.x - p, cell.y - o);
          if (!this.cellsHash[candidate.key()]) {
            if (candidate.reproduce(this)) {
              this.cellsHash[candidate.key()] = candidate;
            }
          }
        }
      }
    }
  }
}

module.exports = Colony;
