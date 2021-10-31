import re

from marko import block

taskpattern = re.compile(r' {,3}[ \t\n\r\f]')

# need to replace listitem because that's what's instantiated by the List
class TaskListItem(block.ListItem):
#class TaskListItem(block.BlockElement):
    """List item element. It can only be created by List.parse"""
    override = True
    _parse_info = (0, "", 0, "", None, None)
    virtual = True
    _tight = False
    pattern = re.compile(r" {,3}(\d{1,9}[.)]|[*\-+])[ \t\f]\[[DW +s*X!]\][ \t\f]")

    def __init__(self, statusdict = None):  # type: () -> None
        # TODO process dict
        indent, bullet, mid, tail, self.uuid, self.status = self._parse_info
#        self._prefix = " " * indent + re.escape(bullet) + " " * mid
        self._prefix = " " * indent + re.escape(bullet + f" [{self.status}]") + " " * mid
        self._second_prefix = " " * (len(bullet) + indent + (mid or 1))

    @classmethod
    def parse_leading(cls, line):  # type: (str) -> Tuple[int, str, int, str, str, str]
        line = line.expandtabs(4)
        stripped_line = line.lstrip()
        indent = len(line) - len(stripped_line)
        temp = stripped_line.split(None, 1)
        bullet = temp[0]
        uuid = None
        if len(temp) == 1:
            mid = 0
            tail = ""
            status = None
        else:
            status = temp[1][1]
            # strip tail
            temp = temp[1][2:].split(None, 1)
            # parse uuid
            temp = temp[1].rsplit(None, 1)
            if len(temp) == 2 and temp[1][0] == '#':
              uuid = temp[1][1:]
            # FIXME compute mid properly
            mid = len(stripped_line) - len("".join(temp))
            if mid > 4:
                mid = 1
            tail = "" if len(temp) == 1 else temp[0]
        # FIXME how to consume uuid tag and exclude it from inline?
        return indent, bullet, mid, tail, uuid, status

    @classmethod
    def match(cls, source):  # type: (Source) -> bool
        if block.parser.block_elements["ThematicBreak"].match(source):  # type: ignore
            return False
        if not source.expect_re(cls.pattern):
            # FIXME figure out how to pass to parent class and do normal listitem
            return False
        next_line = source.next_line(False)
        assert next_line is not None
        prefix_pos = 0
        stripped_line = next_line
        for i in range(1, len(next_line) + 1):
            m = re.match(source.prefix, next_line[:i].expandtabs(4))
            if not m:
                continue
            if m.end() > prefix_pos:
                prefix_pos = m.end()
                stripped_line = next_line[:i].expandtabs(4)[prefix_pos:] + next_line[i:]
        indent, bullet, mid, tail, uuid, status = cls.parse_leading(stripped_line)  # type: ignore
        parent = source.state
        assert isinstance(parent, block.List)
        if (
            parent.ordered
            and not bullet[:-1].isdigit()
            or bullet[-1] != parent.bullet[-1]
        ):
            return False
        if not parent.ordered and bullet != parent.bullet:
            return False
        cls._parse_info = (indent, bullet, mid, tail, uuid, status)
        return True

    @classmethod
    def parse(cls, source):  # type: (Source) -> ListItem
        state = cls()
        state.children = []
        with source.under_state(state):
            if not source.next_line().strip():  # type: ignore
                source.consume()
                if not source.next_line() or not source.next_line().strip():  # type: ignore
                    return state
            state.children = block.parser.parse(source)  # type: ignore
        if isinstance(state.children[-1], block.BlankLine):
            # Remove the last blank line from list item
            blankline = state.children.pop()
            if state.children:
                source.pos = blankline._anchor
        return state

class TaskItem:
  elements = [TaskListItem]
#  renderer_mixins = [WikiRendererMixin]

def make_extension(statusdict = {}):
  return TaskItem()


from marko import inline

class InlineTodoItem(inline.InlineElement):
#    pattern = r'\[\[ *(.+?) *| *(.+?) *\]\]'
    pattern = r'\[[DW +S*X!]\][ \t\f] (.*) \#'
    parse_children = False

    @classmethod
    def set_ticks(cls, ticks = "DW +s*X!"):
#        type(self).pattern = ...
        # TODO non-casesensitive
        pattern = re.compile(r"\[[" + ticks + r"]\][ \t\f] (.*) \#[0-9a-f\-]{32}")
