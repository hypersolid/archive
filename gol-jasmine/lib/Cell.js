function Cell(x, y) {
  this.x = x;
  this.y = y;
  this.dead = false;
}

Cell.prototype.in_range = function(another_cell, distance) {
  var xdiff = Math.abs(this.x - another_cell.x);
  var ydiff = Math.abs(this.y - another_cell.y);
  return xdiff <= distance && ydiff <= distance;
};

Cell.prototype.neighbour = function(another_cell) {
  return this.in_range(another_cell, 1);
};

Cell.prototype.adjustent = function(another_cell) {
  return this.in_range(another_cell, 2);
};

Cell.prototype.equal = function(another_cell) {
  return this.x == another_cell.x && this.y == another_cell.y;
};

Cell.prototype.neighbours_count = function(colony) {
  var count = 0;

  for (var p = -1; p < 2; p++) {
    for (var o = -1; o < 2; o++) {
      if (p != 0 || o != 0) {
        var key = (this.x - p) + '_' + (this.y - o);
        if (colony.cellsHash[key]) { count++; }
      }
    }
  }

  return count;
};

Cell.prototype.liveOrDie = function(colony) {
  var count = this.neighbours_count(colony);
  return count > 1 && count < 4;
};

Cell.prototype.reproduce = function(colony) {
  var count = this.neighbours_count(colony);
  return count == 3;
};

Cell.prototype.key = function() {
  return this.x + '_' + this.y;
}

module.exports = Cell;
