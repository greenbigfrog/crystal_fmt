require "../spec_helper"

def default_data : Array(Array(String | Nil))
  Array(Array(String | Nil)).new << ["a", "b"] << ["c", nil]
end

describe Table do
  # data = reset_data()
  it "should be initializable with a full matrix" do
    t = Table.new(default_data())
    t.should(be_a(Table))
  end
  it "should be initializable with an array of Columns" do
    c = Column.new(Array(String | Nil).new + ["1", "22", nil, "333", "4444"])
    cols = Array(Column).new
    cols.push(c)
    t = Table.new(cols)
    t.should(be_a(Table))
  end
  it "should not be initializable with uneven columns" do
    c = Column.new(Array(String | Nil).new + ["1", "22", nil, "333", "4444"])
    c2 = Column.new(Array(String | Nil).new + ["1", "22", nil, "333", "4444", "5555"])
    cols = Array(Column).new
    cols.push(c)
    cols.push(c2)

    expect_raises(MissingTableData) do
      t = Table.new(cols)
    end
  end
  it "should raise MissingTableData when given uneven matrix" do
    data = default_data()
    data << Array(String | Nil).new + [nil]
    expect_raises (MissingTableData) do
      t = Table.new(data)
    end
  end

  it "should extract columns from data" do
    t = Table.new(default_data())
    columns = t.extract_columns(t.data)
    columns.size.should(eq(2))
    columns.first.size.should(eq(2))
    columns.last.size.should(eq(2))
    columns.first.strings[0].should(eq("a"))
    columns.last.strings[-1].should(eq(nil))
  end

  it "should know how wide it is before extracting columns" do
    data = Array(Array(String | Nil)).new << ["12345", "6"] << ["c", nil]
    t = Table.new(data)
    t.width.should(eq(6))
  end
  it "should know how wide it is after extracting columns" do
    data = Array(Array(String | Nil)).new << ["12345", "6"] << ["c", nil]
    t = Table.new(data)
    t.extract_columns(t.data)
    t.width.should(eq(6))
  end
  it "should know how wide it is when empty" do
    t = Table.new(Array(Array(String | Nil)).new)
    t.width.should(eq(0))
  end

  it "should return initialization columns" do
    c = Column.new(Array(String | Nil).new + ["1", "22", nil, "333", "4444"])
    cols = Array(Column).new
    cols.push(c)
    t = Table.new(cols)
    t.extract_columns(t.data).should(be(cols))
  end

  it "should extract columns from data after adding a row" do
    t = Table.new(default_data())
    t.add_row(Array(String | Nil).new + ["e", "f"])
    columns = t.extract_columns(t.data)
    columns.size.should(eq(2))
    columns.first.size.should(eq(3))
    columns.last.size.should(eq(3))
    columns.first.strings[0].should(eq("a"))
    columns.last.strings[-1].should(eq("f"))
  end

  it "should create one line of text per row" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    t.format.split("\n").size.should(eq(3)) # +1 for header divider
  end
  it "should allow you to add rows" do
    t = Table.new(default_data())
    t.add_row(Array(String | Nil).new + ["e", "f"])
    t.data.size.should(eq(3))
    t.data.inspect.should(eq("[[\"a\", \"b\"], [\"c\", nil], [\"e\", \"f\"]]"))
    # [["a", "b"], ["c", nil]]
  end

  it "should not allow you to add rows to tables initialized with Array(Column)" do
    c = Column.new(Array(String | Nil).new + ["1", "22", nil, "333", "4444"])
    cols = Array(Column).new
    cols.push(c)
    t = Table.new(cols)
    expect_raises(Exception) do
      t.add_row(Array(String | Nil).new + ["e", "f"])
    end
  end
  it "should format correctly after adding a row" do
    # because it didn't once
    t = Table.new(default_data())
    t.add_row(Array(String | Nil).new + ["e", "f"])
    t.data.size.should(eq(3))
    t.data.inspect.should(eq("[[\"a\", \"b\"], [\"c\", nil], [\"e\", \"f\"]]"))
    t.format.split("\n").size.should(eq(4)) # +1 for header divider
  end

  it "should raise MissingTableData when added badly sized row" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    expect_raises (MissingTableData) do
      t.add_row(Array(String | Nil).new + ["d"])
    end
  end
  it "should allow you to add a row of any size to an empty table" do
    t = Table.new
    t.add_row(Array(String | Nil).new + ["d"])
    t = Table.new
    t.add_row(Array(String | Nil).new + ["e", "f"])
  end

  it "should format with | between each item" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    formatted = t.format
    formatted.includes?("a | b").should(be_true())
    formatted.includes?("c |  ").should(be_true())
  end

  it "should start rows with \"| \"" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    formatted = t.format
    formatted.includes?("| a").should(be_true())
    formatted.includes?("| c").should(be_true())
  end
  it "should end rows with \" |\"" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    formatted = t.format
    formatted.includes?("b |").should(be_true())
    formatted.includes?("  |").should(be_true())
  end

  it "should have a configurable left border" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    options = Hash(Symbol, String | Bool).new
    options[:left_border] = "X "
    formatted = t.format(options)
    formatted.includes?("X a").should(be_true())
    formatted.includes?("X c").should(be_true())
  end
  it "should have a configurable right border" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    options = Hash(Symbol, String | Bool).new
    options[:right_border] = " X"
    formatted = t.format(options)
    formatted.includes?("b X").should(be_true())
    formatted.includes?("  X").should(be_true())
  end
  it "should have a configurable divider" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    options = Hash(Symbol, String | Bool).new
    options[:divider] = " X "
    formatted = t.format(options)
    formatted.includes?("a X b").should(be_true())
    formatted.includes?("c X  ").should(be_true())
  end

  it "should divide the header by default" do
    t = Table.new(default_data())
    t.add_row(Array(String | Nil).new + ["wide", "rows"])
    # [["a", "b"], ["c", nil], ["wide", "rows"]]
    formatted = t.format
    rows = formatted.split("\n")
    rows.size.should(eq(4))
    rows[1].should(eq("| ---- | ---- |"))
  end
  it "should allow custom header divider" do
    t = Table.new(default_data())
    t.add_row(Array(String | Nil).new + ["wide", "rows"])
    # [["a", "b"], ["c", nil], ["wide", "rows"]]
    options = Hash(Symbol, String | Bool).new
    options[:header_divider] = "x"

    formatted = t.format(options)
    rows = formatted.split("\n")
    rows.size.should(eq(4))
    rows[1].should(eq("| xxxx | xxxx |"))
  end
  it "should not allow a header divider > 1 character" do
    t = Table.new(default_data())
    # [["a", "b"], ["c", nil]]
    options = Hash(Symbol, String | Bool).new
    options[:header_divider] = "123"
    expect_raises Exception do
      t.format(options)
    end
  end
end
