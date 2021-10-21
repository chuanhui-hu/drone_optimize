% calculate the drag on the projected area

function fd = cal_fd(rho, CD_body, A, v)
fd = 0.5*rho*CD_body*A*v^2;
end
