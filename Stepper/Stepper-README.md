# Stepper Motor Control

(This Markdown file can be viewed best by installing GitHub Flavored Markdown plugin from the Eclipse Marketplace.)

The "Stepper" project models control of a stepper motor which controls a valve.

Unlike servo-motors, a stepper motor moves a discrete number of steps.

There are three different controllers in the same project:
1.  Single-step controller for a *robust* valve which will not be harmed if ordered to close when it's already closed, or open when it's full open.
2.  Single-step controller for a *fragile* valve which must not be further closed when closed, or further opened when full-open.
3.  Multi-step controller for a *fragile* valve.

This last controller is the most realistic, and complex because while it's performing a multi-step operation, 
the system may command a different desired position.

Top-level system implementations can be found in PositionControl.aadl.  
Right-click on one of those in the Outline window to Instantiate (generate an instance model).
These will be created in an "instances" folder inside the "packages" folder.
Right-click on the generated instance file (*.aaxl2), and choose "Generate BLESS Verification Conditions".




