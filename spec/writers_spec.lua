local treedoc = require "_treedoc"
local conv = require "treedoc.writers.markdown"
local ut = require "treedoc.utils"

local eq = assert.are.same

vim.treesitter.language.add("html", {
   path = vim.fn.expand "~/.luarocks/lib/luarocks/rocks-5.1/tree-sitter-html/0.0.29-1/parser/html.so",
})

describe("markdown", function()
   it("should convert simple element", function()
      local ast = treedoc.read([[<h2>sdasdad</h2>]], "html")
      local expected = "## sdasdad"
      local res = treedoc.write(ast, "markdown")
      eq(expected, res)
   end)

   it("should do attr", function()
      local ast = treedoc.read([[<a href="google.com">google</a>]], "html")
      local expected = "[google](google.com)"
      local res = treedoc.write(ast, "markdown")
      eq(expected, res)
   end)

   it("should do nested", function()
      local ast = treedoc.read([[<h1><a href="g.com">google</a></h1>]], "html")
      local expected = "# [google](g.com)"
      local res = treedoc.write(ast, "markdown")
      eq(expected, res)
   end)

   it("img", function()
      local ast = treedoc.read([[<img src="https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg" referrerpolicy="no-referrer"></img>]], "html")
      local expected = "![image](https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg)"
      local res = treedoc.write(ast, "markdown")
      eq(expected, res)
   end)
   --    it("should convert markdown to html", function()
   --       local ast = treedoc.read(
   --          [[
   -- <div>
   --   <h1>Heading</h1>
   --   <h2>Heading2</h2>
   --   <ol>
   --     <li><a href="g.com">google</a> is shasdasd</li>
   --     <li>Item 2</li>
   --     <li><img src="https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg" referrerpolicy="no-referrer"></li>
   --   </ol>
   -- </div>
   -- ]],
   --          "html"
   --       )
   --
   --       local expected = [[# Heading
   --       ## Heading2
   --       1. [google](g.com) is shasdasd
   --       2. Item 2
   --       3. ![image](https://erbingeditor.diershoubing.com/38/2024/09/06/0938026436.jpg)]]
   --       local res = treedoc.write(ast, "markdown")
   --       eq(expected, res)
   --    end)
end)

it("should do figure", function()
   local src = [[
   <img src="https://image.gcores.com/11ad024be82799c36e4f5b58fff53875-1920-1080.jpg?x-oss-process=image/resize,limit_1,m_fill,w_626,h_292/quality,q_90" />
   <p>Capcom第一开发组宣布，《生化危机4 重制版》销量现已突破800万份。</p>

   <div><figure><img src="https://image.gcores.com/760b0e8d6f3d7d685ce2032b519ac869-556-277.png?x-oss-process=image/resize,limit_1,m_lfit,w_700,h_2000/quality,q_90/watermark,image_d2F0ZXJtYXJrLnBuZw,g_se,x_10,y_10" alt=""></figure></div>

   <div><figure><img src="https://image.gcores.com/df239e4f2be2a39285b090fe5332bb58-1920-1080.jpg?x-oss-process=image/resize,limit_1,m_lfit,w_700,h_2000/quality,q_90/watermark,image_d2F0ZXJtYXJrLnBuZw,g_se,x_10,y_10" alt=""></figure></div>

   <p></p>
   ]]

   local md = function(str)
      local ast = treedoc.read(str, "html")
      for _, v in ipairs(ast.blocks) do
         print(ut.type(v))
         -- print(i, v.tag)
      end
      return treedoc.write(ast, "markdown")
   end
   -- TODO:
   -- print(md(src))
end)

it("should do figure", function()
   local src = [[
<dl> <dt>Reset</dt> <dd> Occurs when the user presses the reset button. This is also where the program counter starts when the NES powers on. </dd> <dt>IRQ</dt> <dd> Stands for Interrupt ReQuest. This interrupt can only be fired if a game uses a mapper or uses the <code>BRK</code> instruction. This request can be enabled and disabled with the <code>CLI</code> and <code>SEI</code> instructions. </dd> <dt>NMI</dt> <dd> Stands for Non-Maskable Interrupt because there are no instructions to enable and disable this interrupt. It occurs when the <a href="https://en.wikipedia.org/wiki/Vertical_blanking_interval">vertical blank</a> begins. </dd> </dl>
]]

   local md = function(str)
      local ast = treedoc.read(str, "html")
      return treedoc.write(ast, "markdown")
   end
   local expected = [[Reset 
Occurs when the user presses the reset button. This is also where the program counter starts when the NES powers on.

IRQ
Stands for Interrupt ReQuest. This interrupt can only be fired if a game uses a mapper or uses the `BRK` instruction. This request can be enabled and disabled with the `CLI` and `SEI` instructions.

NMI
Stands for Non-Maskable Interrupt because there are no instructions to enable and disable this interrupt. It occurs when the [vertical blank](https://en.wikipedia.org/wiki/Vertical_blanking_interval) begins.

]]

   -- eq(expected, md(src))
end)

it("should do figure", function()
   local src = [[
<table>
   <tr>
      <th></th>
      <th style="width: 44%;">Debug Mode</th>
      <th>Release Mode</th>
   </tr>
   <tr>
      <th>1</th>
      <td>2</td>
   </tr>
</table>
]]
   local md = function(str)
      local ast = treedoc.read(str, "html")
      -- Pr(ast)
      return treedoc.write(ast, "markdown")
   end
   md(src)
end)

it("should do big file", function()
   local src = [[
<blockquote>  <p>Original article: <a href="https://gpanders.com/blog/whats-new-in-neovim-0-7">https://gpanders.com/blog/whats-new-in-neovim-0-7</a></p></blockquote><p>Neovim 0.7 was just released, bringing with it lots of new features (and ofcourse plenty of bug fixes). You can find the full release notes<a href="https://github.com/neovim/neovim/releases/tag/v0.7.0">here</a>, but in this post I’ll cover just a few of the newadditions.</p><h2 id="table-of-contents">Table of Contents</h2><ul>  <li><a href="#lua-everywhere">Lua everywhere!</a></li>  <li><a href="#distinguishing-modifier-keys">Distinguishing modifier keys</a></li>  <li><a href="#global-statusline">Global statusline</a></li>  <li><a href="#filetypelua">filetype.lua</a></li>  <li><a href="#client-server-communication">Client-server communication</a></li>  <li><a href="#looking-ahead-to-08">Looking ahead to 0.8</a></li></ul><h2 id="lua-everywhere">Lua everywhere!</h2><p>Neovim 0.5 saw the introduction of Lua as a first-class citizen in the Neovimecosystem: Lua could now be used in the user’s init file, plugins,colorschemes, ftplugins, etc. Basically, anywhere that you could use a <code class="language-plaintext highlighter-rouge">.vim</code>file, you could now use <code class="language-plaintext highlighter-rouge">.lua</code> instead.</p><p>However, there were still some shortcomings in the Lua API at that time.Notably absent was the ability to create autocommands in Lua, as well as bindkey mappings directly to Lua functions. In order to do either of these things,users needed to resort to workarounds involving a round trip through Vimscriptconversion, which is a bit clunky:</p><div class="language-lua highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c1">-- Using a Lua function in a key mapping prior to 0.7</span><span class="kd">local</span> <span class="k">function</span> <span class="nf">say_hello</span><span class="p">()</span>    <span class="nb">print</span><span class="p">(</span><span class="s2">"Hello world!"</span><span class="p">)</span><span class="k">end</span><span class="n">_G</span><span class="p">.</span><span class="n">my_say_hello</span> <span class="o">=</span> <span class="n">say_hello</span><span class="n">vim</span><span class="p">.</span><span class="n">api</span><span class="p">.</span><span class="n">nvim_set_keymap</span><span class="p">(</span><span class="s2">"n"</span><span class="p">,</span> <span class="s2">"&lt;leader&gt;H"</span><span class="p">,</span> <span class="s2">"&lt;Cmd&gt;call v:lua.my_say_hello()&lt;CR&gt;"</span><span class="p">,</span> <span class="p">{</span><span class="n">noremap</span> <span class="o">=</span> <span class="kc">true</span><span class="p">})</span></code></pre></div></div><p>The situation was similar for autocommands and custom user commands.</p><p>In Neovim 0.7, it is now possible to use all of the usual configurationprimitives (key mappings, autocommands, user commands, etc.) directly in Lua,with no Vimscript conversion necessary. This also makes it possible to bindkey mappings and autocommands directly to <em>local</em> Lua functions:</p><div class="language-lua highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c1">-- Using a Lua function in a key mapping in 0.7</span><span class="n">vim</span><span class="p">.</span><span class="n">api</span><span class="p">.</span><span class="n">nvim_set_keymap</span><span class="p">(</span><span class="s2">"n"</span><span class="p">,</span> <span class="s2">"&lt;leader&gt;H"</span><span class="p">,</span> <span class="s2">""</span><span class="p">,</span> <span class="p">{</span>    <span class="n">noremap</span> <span class="o">=</span> <span class="kc">true</span><span class="p">,</span>    <span class="n">callback</span> <span class="o">=</span> <span class="k">function</span><span class="p">()</span>        <span class="nb">print</span><span class="p">(</span><span class="s2">"Hello world!"</span><span class="p">)</span>    <span class="k">end</span><span class="p">,</span><span class="p">})</span><span class="c1">-- Creating an autocommand in 0.7</span><span class="n">vim</span><span class="p">.</span><span class="n">api</span><span class="p">.</span><span class="n">nvim_create_autocmd</span><span class="p">(</span><span class="s2">"BufEnter"</span><span class="p">,</span> <span class="p">{</span>    <span class="n">pattern</span> <span class="o">=</span> <span class="s2">"*"</span><span class="p">,</span>    <span class="n">callback</span> <span class="o">=</span> <span class="k">function</span><span class="p">(</span><span class="n">args</span><span class="p">)</span>        <span class="nb">print</span><span class="p">(</span><span class="s2">"Entered buffer "</span> <span class="o">..</span> <span class="n">args</span><span class="p">.</span><span class="n">buf</span> <span class="o">..</span> <span class="s2">"!"</span><span class="p">)</span>    <span class="k">end</span><span class="p">,</span>    <span class="n">desc</span> <span class="o">=</span> <span class="s2">"Tell me when I enter a buffer"</span><span class="p">,</span><span class="p">})</span><span class="c1">-- Creating a custom user command in 0.7</span><span class="n">vim</span><span class="p">.</span><span class="n">api</span><span class="p">.</span><span class="n">nvim_create_user_command</span><span class="p">(</span><span class="s2">"SayHello"</span><span class="p">,</span> <span class="k">function</span><span class="p">(</span><span class="n">args</span><span class="p">)</span>    <span class="nb">print</span><span class="p">(</span><span class="s2">"Hello "</span> <span class="o">..</span> <span class="n">args</span><span class="p">.</span><span class="n">args</span><span class="p">)</span><span class="k">end</span><span class="p">,</span> <span class="p">{</span>    <span class="n">nargs</span> <span class="o">=</span> <span class="s2">"*"</span><span class="p">,</span>    <span class="n">desc</span> <span class="o">=</span> <span class="s2">"Say hi to someone"</span><span class="p">,</span><span class="p">})</span></code></pre></div></div><p>You may notice that <code class="language-plaintext highlighter-rouge">nvim_set_keymap</code> must set the Lua callback as a key inthe final table argument, while <code class="language-plaintext highlighter-rouge">nvim_create_user_command</code> can pass thecallback function directly as a positional parameter. This is a consequence ofNeovim’s strict API contract, which mandates that after an API function makesit into a stable release, it’s signature <em>must not</em> change in any way.However, because <code class="language-plaintext highlighter-rouge">nvim_create_user_command</code> is a new API function, we are ableto add a bit of convenience by making its second argument accept either astring or a function.</p><p>Neovim 0.7 also includes a Lua-only convenience function <code class="language-plaintext highlighter-rouge">vim.keymap.set</code> foreasily creating new key mappings:</p><div class="language-lua highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="n">vim</span><span class="p">.</span><span class="n">keymap</span><span class="p">.</span><span class="n">set</span><span class="p">(</span><span class="s2">"n"</span><span class="p">,</span> <span class="s2">"&lt;leader&gt;H"</span><span class="p">,</span> <span class="k">function</span><span class="p">()</span> <span class="nb">print</span><span class="p">(</span><span class="s2">"Hello world!"</span><span class="p">)</span> <span class="k">end</span><span class="p">)</span></code></pre></div></div><p><code class="language-plaintext highlighter-rouge">vim.keymap.set</code> differs from <code class="language-plaintext highlighter-rouge">nvim_set_keymap</code> in the following ways:</p><ul>  <li>It can accept either a string or a Lua function as its 3rd argument.</li>  <li>It sets <code class="language-plaintext highlighter-rouge">noremap</code> by default, as this is what users want 99% of thetime.</li></ul><p>The help docs contain much more information: run <code class="language-plaintext highlighter-rouge">:h vim.keymap.set</code> in Neovimto learn more.</p><p>Finally, users can now use the API function <code class="language-plaintext highlighter-rouge">nvim_set_hl</code> to modify globalhighlight groups (the equivalent of using <code class="language-plaintext highlighter-rouge">:hi</code>), opening the door to pure-Luacolorschemes.</p><h2 id="distinguishing-modifier-keys">Distinguishing modifier keys</h2><p>Being a terminal based application, Neovim has long been subject to theconstraints of terminal emulators, one of which being that many keys areencoded the same and thus indistinguishable to applications running in theterminal. For example, <code class="language-plaintext highlighter-rouge">&lt;Tab&gt;</code> and <code class="language-plaintext highlighter-rouge">&lt;C-I&gt;</code> use the same representation, as do<code class="language-plaintext highlighter-rouge">&lt;CR&gt;</code> and <code class="language-plaintext highlighter-rouge">&lt;C-M&gt;</code>. This has long meant that it is not possible to separatelymap <code class="language-plaintext highlighter-rouge">&lt;C-I&gt;</code> and <code class="language-plaintext highlighter-rouge">&lt;Tab&gt;</code>: mapping one necessarily maps both.</p><p>This has long been a point of annoyance and there are multiple solutions inthe wild to address it. Neovim uses Paul Evans’ <a href="http://www.leonerd.org.uk/code/libtermkey/">libtermkey</a>, which in turnmakes use of Evans’ own <a href="http://www.leonerd.org.uk/hacks/fixterms/">fixterms</a> proposal for encoding modifier keys in anunambiguous way. As long as the terminal emulator controlling Neovim sendskeys encoded in this way, Neovim can correctly interpret them.</p><p>Neovim 0.7 now correctly <a href="https://github.com/neovim/neovim/pull/17825">distinguishes these modifier key combos</a> inits own input processing, so users can now map e.g. <code class="language-plaintext highlighter-rouge">&lt;Tab&gt;</code> and <code class="language-plaintext highlighter-rouge">&lt;C-I&gt;</code>separately. In addition, Neovim sends an <a href="https://github.com/neovim/neovim/pull/17844">escape sequence</a> on startupthat signals to the controlling terminal emulator that it supports this styleof key encoding. Some terminal emulators (such as iTerm2, foot, and tmux) usethis sequence to programatically enable the different encoding.</p><p>A note of warning: this cuts both ways! You may find that existing mappings to<code class="language-plaintext highlighter-rouge">&lt;Tab&gt;</code> or <code class="language-plaintext highlighter-rouge">&lt;C-I&gt;</code> (or <code class="language-plaintext highlighter-rouge">&lt;CR&gt;</code>/<code class="language-plaintext highlighter-rouge">&lt;C-M&gt;</code>) no longer work. The fix is easy,however; simply modify your mapping to use the actual key you want to use.</p><p>In addition to disambiguating these modifier pairs, this also enables newkey mappings that were not possible before, such as <code class="language-plaintext highlighter-rouge">&lt;C-;&gt;</code> and <code class="language-plaintext highlighter-rouge">&lt;C-1&gt;</code>.</p><p>Support for this depends largely on the terminal you are using, so this willnot affect all users.</p><h2 id="global-statusline">Global statusline</h2><p>Neovim 0.7 introduces a new “global” statusline, which can be enabled bysetting <code class="language-plaintext highlighter-rouge">laststatus=3</code>. Instead of having one statusline per window, theglobal statusline always runs the full available width of Neovim’s containingwindow. This makes it useful to display information that does not changeper-window, such as VCS information or the current working directory. Manystatusline plugins are already making use of this new feature.</p><h2 id="filetypelua">filetype.lua</h2><p>In Neovim 0.7 there is a new (experimental) way to do filetype detection. Aquick primer on filetype detection: when you first start Neovim it sources afile called <code class="language-plaintext highlighter-rouge">filetype.vim</code> in the <code class="language-plaintext highlighter-rouge">$VIMRUNTIME</code> directory. This file createsseveral hundred <code class="language-plaintext highlighter-rouge">BufRead,BufNewFile</code> autocommands whose sole purpose is toinfer the filetype of the file based on information about the file, mostcommonly the file’s name or extension, but sometimes also using the file’scontents.</p><p>If you profile your startup time with <code class="language-plaintext highlighter-rouge">nvim --startuptime</code> you will noticethat <code class="language-plaintext highlighter-rouge">filetype.vim</code> is one of the slowest files to load. This is because it isexpensive to create so many autocommands. An alternative way to do filetypedetection is to instead create one single autocommand that fires for <em>every</em>new buffer and then tries to match the filetype through a sequential series ofsteps. This is what the new <code class="language-plaintext highlighter-rouge">filetype.lua</code> does.</p><p>In addition to using a single autocommand, <code class="language-plaintext highlighter-rouge">filetype.lua</code> uses a table-basedlookup structure, meaning that in many cases filetype detection happens inconstant time. And if your Neovim is compiled with LuaJIT (which it mostlikely is), you also get the benefit of just-in-time compilation for thisfiletype matching.</p><p>This feature is currently <em>opt-in</em> as it does not yet completely match all ofthe filetypes covered by <code class="language-plaintext highlighter-rouge">filetype.vim</code>, although it is very close (I havebeen using it exclusively for many months without any issues). There are twoways to opt-in to this feature:</p><ol>  <li>    <p>Use <code class="language-plaintext highlighter-rouge">filetype.lua</code>, but fallback to <code class="language-plaintext highlighter-rouge">filetype.vim</code></p>    <p>Add <code class="language-plaintext highlighter-rouge">let g:do_filetype_lua = 1</code> to your <code class="language-plaintext highlighter-rouge">init.vim</code> file. This prevents anyregressions in filetype matching and ensures that filetypes are alwaysdetected <em>at least</em> as well as they are with <code class="language-plaintext highlighter-rouge">filetype.vim</code>. However, youwill pay the startup time cost of both <code class="language-plaintext highlighter-rouge">filetype.lua</code> and <code class="language-plaintext highlighter-rouge">filetype.vim</code>.</p>  </li>  <li>    <p>Use only <code class="language-plaintext highlighter-rouge">filetype.lua</code> and do not load <code class="language-plaintext highlighter-rouge">filetype.vim</code> at all</p>    <p>Add both <code class="language-plaintext highlighter-rouge">let g:do_filetype_lua = 1</code> and <code class="language-plaintext highlighter-rouge">let g:did_load_filetypes = 0</code> toyour <code class="language-plaintext highlighter-rouge">init.vim</code>. This will exclusively use <code class="language-plaintext highlighter-rouge">filetype.lua</code> for filetypematching and provides all of the performance benefits outlined above, withthe (small) risk of missed filetype detection.</p>  </li></ol><p>In addition to performance benefits, <code class="language-plaintext highlighter-rouge">filetype.lua</code> also makes it easy toadd custom filetypes. Simply create a new file <code class="language-plaintext highlighter-rouge">~/.config/nvim/filetype.lua</code>and call <code class="language-plaintext highlighter-rouge">vim.filetype.add</code> to create new matching rules. For example:</p><div class="language-lua highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="n">vim</span><span class="p">.</span><span class="n">filetype</span><span class="p">.</span><span class="n">add</span><span class="p">({</span>    <span class="n">extension</span> <span class="o">=</span> <span class="p">{</span>        <span class="n">foo</span> <span class="o">=</span> <span class="s2">"fooscript"</span><span class="p">,</span>    <span class="p">},</span>    <span class="n">filename</span> <span class="o">=</span> <span class="p">{</span>        <span class="p">[</span><span class="s2">"Foofile"</span><span class="p">]</span> <span class="o">=</span> <span class="s2">"fooscript"</span><span class="p">,</span>    <span class="p">},</span>    <span class="n">pattern</span> <span class="o">=</span> <span class="p">{</span>        <span class="p">[</span><span class="s2">"~/%.config/foo/.*"</span><span class="p">]</span> <span class="o">=</span> <span class="s2">"fooscript"</span><span class="p">,</span>    <span class="p">}</span><span class="p">})</span></code></pre></div></div><p><code class="language-plaintext highlighter-rouge">vim.filetype.add</code> takes a table with 3 (optional) keys corresponding to“extension”, “filename”, and “pattern” matching. The value of each table entrycan either be a string (in which case it is interpreted as the filetype) or afunction. For example, you may want to override Neovim’s default behavior ofalways classifying <code class="language-plaintext highlighter-rouge">.h</code> files as C++ headers by using a heuristic that onlysets the filetype to C++ if the header file includes another C++-style header(i.e. one without a trailing <code class="language-plaintext highlighter-rouge">.h</code>):</p><div class="language-lua highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="n">vim</span><span class="p">.</span><span class="n">filetype</span><span class="p">.</span><span class="n">add</span><span class="p">({</span>    <span class="n">extension</span> <span class="o">=</span> <span class="p">{</span>        <span class="n">h</span> <span class="o">=</span> <span class="k">function</span><span class="p">(</span><span class="n">path</span><span class="p">,</span> <span class="n">bufnr</span><span class="p">)</span>            <span class="k">if</span> <span class="n">vim</span><span class="p">.</span><span class="n">fn</span><span class="p">.</span><span class="n">search</span><span class="p">(</span><span class="s2">"</span><span class="se">\\</span><span class="s2">C^#include &lt;[^&gt;.]\\+&gt;$"</span><span class="p">,</span> <span class="s2">"nw"</span><span class="p">)</span> <span class="o">~=</span> <span class="mi">0</span> <span class="k">then</span>                <span class="k">return</span> <span class="s2">"cpp"</span>            <span class="k">end</span>            <span class="k">return</span> <span class="s2">"c"</span>        <span class="k">end</span><span class="p">,</span>    <span class="p">},</span><span class="p">})</span></code></pre></div></div><p>We are bringing <code class="language-plaintext highlighter-rouge">filetype.lua</code> closer to full parity with <code class="language-plaintext highlighter-rouge">filetype.vim</code> everyday. The goal is to make it the default in Neovim 0.8 (with the ability toopt-out to the traditional <code class="language-plaintext highlighter-rouge">filetype.vim</code>).</p><h2 id="client-server-communication">Client-server communication</h2><p>Neovim 0.7 brings some of the features of <a href="https://github.com/mhinz/neovim-remote">neovim-remote</a> into the coreeditor. You can now use <code class="language-plaintext highlighter-rouge">nvim --remote</code> to open a file in an already runninginstance of Neovim. An example:</p><div class="language-bash highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c"># In one shell session</span>nvim <span class="nt">--listen</span> /tmp/nvim.sock<span class="c"># In another shell session, opens foo.txt in the first Nvim instance</span>nvim <span class="nt">--server</span> /tmp/nvim.sock <span class="nt">--remote</span> foo.txt</code></pre></div></div><p>One use case for the new remote functionality is the ability to open filesfrom the embedded terminal emulator in the primary Neovim instance, ratherthan creating an embedded Neovim instance running inside Neovim itself.</p><h2 id="looking-ahead-to-08">Looking ahead to 0.8</h2><p>Neovim is a loosely structured project of motivated individuals who do thework for fun; thus, any roadmap is always a bit of a guessing game. However,there are some things already brewing that you <em>might</em> see in Neovim 0.8:</p><ul>  <li>Improvements to Treesitter support</li>  <li>“Projects” support for LSP</li>  <li><a href="https://github.com/neovim/neovim/pull/9496">Anti-conceal</a></li>  <li><a href="https://github.com/neovim/neovim/pull/10071">Fully remote TUI</a></li>  <li>And more…</li></ul>
]]

   local md = function(str)
      local ast = treedoc.read(str, "html")
      -- Pr(ast)
      return treedoc.write(ast, "markdown")
   end
   -- print(md(src))
end)
