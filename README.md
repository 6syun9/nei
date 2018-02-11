# Labmode

**Notebooks. In plaintext. In *your* editor.**


<img src="https://s3-eu-west-1.amazonaws.com/misc-static-assets/labmode-README-example.gif" width="90%"><img>

The goal of labmode is to allow Python [Jupyter
notebooks](https://jupyter.org/) to be edited efficiently as plaintext,
allowing you to use all the text and code editing tools you are familiar
with to work as effectively with notebooks as with regular code files.

The above GIF shows a demo of labmode being used in emacs on the
left-hand side while the results reflected live on the right-hand side
in Firefox. The file in emacs is a regular Python file using vanilla
Python syntax - the yellow code prompts are simply pretty printed for
clarity. For instance, the yellow ``In[1]`` is simply the visual
representation of the comment ``# In[1]``.

Labmode is composed of three components: a Python server using
[tornado](http://www.tornadoweb.org/en/stable/) which receives commands
from the editor via websockets, the HTML and Javascript that runs in the
browser and finally the code that integrates with the editor. Currently
this last component is elisp as the first editor to be supported will be
[emacs](http://emacs.org). As the server and web component are editor
agnostic, there is no reason labmode cannot be extended to support any
text editor that has support for websockets.
   
**Labmode is currently an experimental prototype and should not be
considered stable.**

## Python dependencies

You can conda install the three python dependencies as follows:

```
conda install tornado ansi2html jupyter_client
```

The ``ansi2html`` dependency will soon not be necessary.

## Browser configuration

Labmode is written in ES6 and is not yet configured to compile to ES5
with babel. This means you will need a recent browser and you may need
to enable JavaScript module support in your browser:

Firefox 58: Go to [about:config](about:config) and set
``dom.moduleScripts.enabled`` to ``true``.

Chrome: Go to [chrome://flags/](chrome://flags]) and set
``enable-javascript-harmony`` to 'Enabled'.

These steps will not be necessary as browsers start to enable these
settings by default and once labmode offers an ES5 version of the
Javascript code.

## Tips

Labmode currently supports [miniconda3](https://conda.io/miniconda.html)
environments. You can make a python file automatically enable labmode
and switch to a miniconda3 environment (here ``"example-env"``) by
putting this line at the top of your Python file:

```
# -*- mode: python; labmode-env : "example-env"; eval: (lab-mode)-*-
```

The environment used will have to satisfy the Python dependencies listed
above. If you don't use miniconda you will need to set the
``labmode-python-path`` elisp variable.

## Emacs configuration

Labmode does not yet have an emacs package but it only has two elisp
dependencies given a recent version of emacs:
[``s``](https://melpa.org/#/s) and
[``websocket``](https://melpa.org/#/websocket). These can be easily
installed using the ``package-list-packages`` command if you have
pointed to a suitable elisp package repository such as
[MELPA](https://melpa.org/).

You will also need to add labmode to your ``.emacs`` file by pointing to
the ``emacs`` subdirectory of this repository:

```elisp
(add-to-list 'load-path "~/labmode/emacs")
(require 'lab-mode)
```

Eventually a MELPA package will be offered for labmode.

### Usage

To get started, the most important keybindings are ``C-c v`` to open a
view of the buffer in the selected browser (Firefox by default), ``C-c
c`` to insert a code cell, ``C-c m`` to add a markdown cell and ``C-c
e`` to execute a cell.


```elisp
  (define-key map (kbd "C-c W") 'labmode-write-notebook)
  (define-key map (kbd "C-c I") 'labmode-insert-notebook)
  (define-key map (kbd "C-c E") 'labmode-exec-by-line)
  (define-key map (kbd "C-c L") 'labmode-clear-all-cell-outputs)
  (define-key map (kbd "C-c C") 'labmode-update-css)
  
  (define-key map (kbd "C-c w") 'labmode-move-cell-up)
  (define-key map (kbd "C-c s") 'labmode-move-cell-down)
  (define-key map (kbd "C-c <down>") 'labmode-move-point-to-next-cell)
  (define-key map (kbd "C-c <up>") 'labmode-move-point-to-previous-cell)
  (define-key map (kbd "C-c c") 'labmode-insert-code-cell)
  (define-key map (kbd "C-c m") 'labmode-insert-markdown-cell)
  (define-key map (kbd "C-c e") 'labmode-exec-by-line-and-move-to-next-cell)
  (define-key map (kbd "C-c i") 'labmode-interrupt-kernel)
  (define-key map (kbd "C-c r") 'labmode-restart-kernel)
  (define-key map (kbd "C-c l") 'labmode-clear-cell-by-line)
  (define-key map (kbd "C-c n") 'labmode-clear-notebook-and-restart)

  (define-key map (kbd "C-c v") 'labmode-view-browser)
  (define-key map (kbd "C-c V") 'labmode-view-notebook)
```

The elisp variable ``labmode-browser`` can be set from 'firefox' to
'chrome' if you prefer to view the notebooks in the Chrome browser.


## Scope of the project

A few notes on the current scope of the project. As the project progress, support for features currently out of scope will be considered.

* At this time, labmode only aims to support Python and IPython syntax.
* The primary focus is currently on ensuring robust emacs support but contributions to support other editors are welcome.
* One key objective is to support rich interactive visualization with [holoviews](http://holoviews.org/) which means supporting [bokeh](https://bokeh.pydata.org/en/latest/) plots. Support for other complex Javascript components such as ipywidgets is currently out of scope of the project.