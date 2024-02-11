\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3}
\ProvidesExplClass {SEUExam} {2023-12-17} {v1.0} {An exam template for SEU}

\AddToHook{package/exam-zh-symbols/before}{%
  \AtBeginDocument{\let\savedsim=\sim}
}
\AddToHook{package/exam-zh-symbols/after}{%
  \AtBeginDocument{\let\sim=\savedsim}
}

% 加载文档类和宏包
\LoadClass {exam-zh}

% 处理文档类选项
\PassOptionsToClass { UTF8 , scheme = chinese, openany } { exam-zh }
\DeclareOption* { \PassOptionsToClass { \CurrentOption } { exam-zh } }
\ProcessOptions*

% 使用 l3keys 定义 \seuexamsetup 配置命令
\NewDocumentCommand \seuexamsetup { m }
  { \keys_set:nn { seu-exam } {#1} }

% 定义 exam 宏包选项

% 试卷头里的年份
\int_new:N \l_seuexam_year_int
\NewDocumentCommand \Year { m }
{ \int_set:Nn \l_seuexam_year_int {#1} }

% 试卷头里的学期
\str_new:N \l_seuexam_semester_str
\NewDocumentCommand \Semester { m }
  { \str_set:Nn \l_seuexam_semester_str {#1} }

% 试卷头里的课程
% 是否期中
\tl_new:N \l_seuexam_course_id
\NewDocumentCommand \CourseID { m }
  {\tl_set:Nn \l_seuexam_course_id {#1} }
  
\tl_new:N \l_seuexam_course_tl
\NewDocumentCommand \Course { m }
  {\tl_set:Nn \l_seuexam_course_tl {#1} }

% 是否期中
\tl_new:N \l_seuexam_suffix_tl
\NewDocumentCommand \Suffix { m }
  {\tl_set:Nn \l_seuexam_suffix_tl {#1 试卷} }

% 试卷头里的类型，如A/B/模拟等
\tl_new:N \l_seuexam_type_tl
\NewDocumentCommand \Type { m }
  { \tl_set:Nn \l_seuexam_type_tl {
      \bool_if:NTF \l__examzh_question_show_paren_answer_bool
      %{\l_seuexam_suffix_tl （#1 卷参考答案）}
      {\l_seuexam_suffix_tl （#1 卷）}
    }
  }

% 试卷适用专业
\tl_new:N \l_seuexam_major_tl
\NewDocumentCommand \Major { m }
  {\tl_set:Nn \l_seuexam_major_tl {#1} }

% 试卷形式
\tl_new:N \l_seuexam_format_tl
\NewDocumentCommand \Format { m }
  {\tl_set:Nn \l_seuexam_format_tl {#1} }

% 试卷时长
\tl_new:N \l_seuexam_duration_tl
\NewDocumentCommand \Duration { m }
  {\tl_set:Nn \l_seuexam_duration_tl {#1} }

% 试卷头计分表中大题的数目
\int_new:N \l_seuexam_num_of_sections_int
\NewDocumentCommand \TotalPart { m }
  { \int_set:Nn \l_seuexam_num_of_sections_int {#1} }

% 标题
\tl_new:N \l_seuexam_title_tl
\tl_set:Nn \l_seuexam_title_tl
  {
    \int_eval:n { \l_seuexam_year_int } -- \int_eval:n {\l_seuexam_year_int + 1} ~学年\,%
    第 \l_seuexam_semester_str{} 学期 \l_seuexam_course_tl \l_seuexam_type_tl\
  }

% PDF 主题信息
\str_new:N \l_seuexam_pdf_subject_str
\NewDocumentCommand \Subject { m }
  { \str_set:Nn \l_seuexam_pdf_subject_str {#1} }
% PDF 关键词信息
\str_new:N \l_seuexam_pdf_keywords_str
\NewDocumentCommand \Keywords { m }
  { \str_set:Nn \l_seuexam_pdf_keywords_str {#1} }

\AtBeginDocument{%
  \hypersetup{
    pdfinfo={
      Title    = {\l_seuexam_title_tl},
      Author   = {\@author},
      Subject  = {\l_seuexam_pdf_subject_str},
      Keywords = {\l_seuexam_pdf_keywords_str},
    },
    colorlinks = true,
    linkcolor  = black,
  }
}

% 输出标题
\RenewDocumentCommand \maketitle { }
  {
    \cleardoublepage
    \chapter{东南大学 \l_seuexam_title_tl}
    \begingroup
    \begin { center }
    \let \footnote \thanks
    {
      \Large \bfseries 东{~}{~}{~}南{~}{~}{~}大{~}{~}{~}学{~}{~}{~}考{~}{~}{~}试{~}{~}{~}试{~}{~}{~}卷 \l_seuexam_type_tl \par
    }
    \end { center }
    \endgroup
    \begingroup
    %\vspace{1em}
    \begin{table}[h]
      \begin{tabularx}{1.0\textwidth} {lll}
          \textbf{课程代码}~\underline{\qquad \, \l_seuexam_course_id \, \qquad}~
          &\textbf{课程名称}~\underline{\l_seuexam_course_tl}~
          &\textbf{考试学期}~\underline{\int_eval:n { \l_seuexam_year_int } -- \int_eval:n {\l_seuexam_year_int + 1} -- \l_seuexam_semester_str{}}\\
          \textbf{适用专业}~\underline{\l_seuexam_major_tl}~
          &\textbf{考试形式}~\underline{\qquad \quad \l_seuexam_format_tl \qquad\quad}~
          &\textbf{考试时长}~\underline{\quad \l_seuexam_duration_tl{~}}
       \end{tabularx}
    \end{table}
    \endgroup
    \begingroup
    \ScoreTable
    \endgroup
  }

% 输出计分表
\RequirePackage{makecell,tabularx}
% we need LaTeX counters and not expl3 ones because of tabularx two-step process
\newcounter{repeatstart}
\newcounter{repeatcurrent}
\newcounter{repeatlast}

\NewDocumentCommand{\repeatcell}{mm}
 {% #1 = number of repeats
  % #2 = key-value pairs
  \oaheix_repeatcell:nn { #1 } { #2 }
 }

\tl_new:N \l__oaheix_repeatcells_body_tl

\keys_define:nn { oaheix/repeatcells }
 {
  text .code:n = \cs_gset_protected:Nn \__oaheix_repeatcell_text:n { #1 },
  start .code:n = \setcounter{repeatstart}{#1},
 }

\cs_new_protected:Nn \oaheix_repeatcell:nn
 {
  \keys_set:nn { oaheix/repeatcells } { #2 }
  \tl_clear:N \l__oaheix_repeatcells_body_tl
  \int_step_inline:nnn
   { \value{repeatstart} + 1 }
   { \value{repeatstart} + #1 }
   {
    \tl_put_right:Nx \l__oaheix_repeatcells_body_tl
     {
      \int_compare:nF { ##1 = \value{repeatstart} + 1 } { & }
      \__oaheix_repeatcell_text:n { ##1 }
     }
   }
  \tl_use:N \l__oaheix_repeatcells_body_tl
  \setcounter{repeatlast} { \int_eval:n { \value{repeatstart} + #1 } }
 }

\NewExpandableDocumentCommand{\lastvalue}{}{\int_eval:n { \value{repeatlast} } }

\AtBeginEnvironment{tabularx}{\setcounter{repeatstart}{0}}

% 计分表制作
\NewDocumentCommand \ScoreTable {}{
\vspace{-10pt}
\renewcommand\arraystretch{1.35}
  \begin{tabularx}{\linewidth}{ |X<{\centering}|*{\l_seuexam_num_of_sections_int}{X<{\centering}|}*{2}{c|}}
    \hline                                                                                                 
      题 \hspace*{1em} 号 & \repeatcell{\l_seuexam_num_of_sections_int }{text={\zhnumber{##1}}} & 成 \hspace*{2em} 绩 \\
    \hline
      得 \hspace*{1em} 分 & \eline{\int_eval:n { \l_seuexam_num_of_sections_int + 1 } } \\
    \hline
    评阅人 & \eline{\int_eval:n { \l_seuexam_num_of_sections_int + 1 } } \\
    \hline
  \end{tabularx}
}

% 页眉页脚
\fancypagestyle{myEmptyPage}{
  \fancyhf{}
  \cfoot{\thepage}
}

\NewDocumentCommand \backcover { }
  {
    \int_if_odd:nTF \c@page
    {
      { \clearpage \hbox:n { } \thispagestyle{empty} }
      { \setcounter{page}{\thepage - 1} }
    }
    {
      { \cleardoublepage \hbox:n { } \thispagestyle{empty} }
      { \setcounter{page}{\thepage - 2} }
    }
  }

\RenewDocumentCommand \cleardoublepage { }
  {
    \clearpage
    \int_if_odd:nF \c@page
      { \hbox:n { } \thispagestyle { empty } \newpage }
  }


\setlength{\parindent}{0em}

\examsetup{
  page = {
    foot-content = {
     第~\thepage~页 \quad 共~\lastpage@lastpage~页
    },
    foot-type = common,
    show-chapter = false,
  },
  sealline = {
    show        = true,
    scope       = mod-2,
    circle-show = false,
    line-type   = dashed,
    odd-info-content = {学号~{\makebox[40mm][c]{\hrulefill}}~{\makebox[10mm][c]{}}~ 姓名~{\makebox[40mm][c]{\hrulefill}}},
    odd-info-xshift = 8mm,
    text = {自~觉~遵~守~考~场~纪~律~{~}{~}{~}{~}~如~考~试~作~弊~{~}{~}{~}{~}~此~答~卷~无~效},
    text-direction-vertical = true,
    text-width = 0.6\textheight,
    %text-format  = \normalfont,
    text-xshift = 14mm
  },
  choices/label=(\Alph*),
  %scoringbox/type = onecolumn,
  symbols/change-frac-style = true,
  symbols/change-dfrac-style = true,
  solution/blank-type = manual,
  solution/show-answer = true,
  solution/label-content = {\color{blue}解},
  question/show-answer = true,
  problem/show-answer = true,
  paren/show-answer = true,
  fillin/show-answer = true,
  paren/text-color=blue,
  fillin/text-color=blue,
  solution/text-color=blue,
}


\RenewDocumentEnvironment{proof}{ O{} }
  {\begin{solution}
  [label-content={\color{blue}证明},blank-type=manual,#1]}
  {\end{solution}}

\RequirePackage{fixdif}
\newdif{\dif}{\mathrm{d}}

\DeclareMathOperator{\re}{\operatorname{e}}
\DeclareMathOperator{\ri}{\operatorname{i}}
\DeclareMathOperator{\cov}{\operatorname{cov}}
\DeclareMathOperator{\sgn}{\operatorname{sgn}}
\DeclareMathOperator{\rot}{\operatorname{\mathbf{rot}}}
\DeclareMathOperator{\grad}{\operatorname{\mathbf{grad}}}
\DeclareMathOperator{\divd}{\operatorname{div}}
\DeclareMathOperator{\ch}{\operatorname{ch}}
\DeclareMathOperator{\sh}{\operatorname{sh}}

\NewDocumentCommand \abs { m }
  {\left| #1 \right|}

\renewcommand{\Re}{\operatorname{Re}}
\renewcommand{\Im}{\operatorname{Im}}
\renewcommand{\le}{\leqslant}
\renewcommand{\leq}{\leqslant}
\renewcommand{\ge}{\geqslant}
\renewcommand{\geq}{\geqslant}
\renewcommand\parallel{\mathrel{/\mskip-2.5mu/}}

\everymath{\displaystyle}
\allowdisplaybreaks

% 以下为兼容性代码
\NewDocumentCommand \makehead {}
  {\maketitle}

% 也可以用正则表达式替换
% \\options\{(.+?)\}[%\n ]+\{(.+?)\}[%\n ]+?\{(.+?)\}[%\n ]+?\{(.+?)\}[%\n ]+?\n
% =>
% \\begin{choices}\n\t\t\\item $1\n\t\t\\item $2\n\t\t\\item $3\n\t\t\\item $4\n\t\\end{choices}\n
\NewDocumentCommand \options { m m m m }
  {
    \begin{choices}
      \item #1
      \item #2
      \item #3
      \item #4
    \end{choices}
  }

% 也可以用正则表达式替换
% \\pickout\{([A-D])\} => \\pickout[$1]
\NewDocumentCommand \pickout { m }
  {\paren[#1]}

% 也可以用正则表达式替换
% \\fillin\{(.+)\} => \\fillin[$1]
% % 此处的兼容性代码实在是不会
% \let\savefillin=\fillin
% \AtBeginDocument{
%   \RenewDocumentCommand \fillin { m }
%     {\savefillin[#1]}
%   }

% 也可以用正则表达式替换
% \\makepart\{(.+?)\}\{(.+?)\} => \\section{$1（$2）}
\NewDocumentCommand \makepart { m m }
  {\section{#1（#2）}}


