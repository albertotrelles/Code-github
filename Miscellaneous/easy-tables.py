import sys
import subprocess

def maketable(nmodels, notes=None):
    strline = "~ &"
    for i in range(1, nmodels + 1):
        if i < nmodels:
            strline += f" ({i}) &"
        elif i == nmodels:
            strline += f" ({i}) "

    text = "\\begin{table}[htb!]\n" + \
           "\\caption{ }\n" + \
           "\\begin{center}\n" + \
           "\\scalebox{1}{\n" + \
           "  \\def\\arraystretch{1.1}\n" + \
           "  \\begin{tabular}{\n" + \
           "    >{\\raggedright\\arraybackslash}p{3cm}\n" + \
           f"    *{{{nmodels}}}{{>{{\\centering\\arraybackslash}}p{{1cm}}}}\n" + \
           "  }\n" + \
           "  \\hline\n" + \
           f"  {strline}\\\\ \n" + \
           "  \\hline \\hline\n" + \
           " \\input{} \\\\ [-3ex]\n" + \
           "  \\hline \\hline\n" + \
           "  \\end{tabular}\n" + \
           "}\n" + \
           "\\end{center}\n" + \
           "\\justifying\n" + \
           "{\\scriptsize \\textbf{Notes:} "
    
    if notes is not None:
        text += f"{notes} "
    
    text += "\\par}\n" + \
            "\\end{table}"

    # Copy the generated text to the clipboard using subprocess
    process = subprocess.Popen(
        ['clip'],
        stdin=subprocess.PIPE,
        shell=True,
    )
    process.communicate(input=text.encode('utf-8'))
    
    return text

if __name__ == "__main__":
    # Ensure we have the right number of arguments
    if len(sys.argv) < 2:
        print("Usage: python call_function.py <nmodels> [notes]")
        sys.exit(1)
    
    # Parse arguments
    try:
        nmodels = int(sys.argv[1])
    except ValueError:
        print("Error: <nmodels> should be an integer.")
        sys.exit(1)
    
    notes = ' '.join(sys.argv[2:]) if len(sys.argv) > 2 else None
    
    # Call the function and print the result
    result = maketable(nmodels, notes)