using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_LastAttack_State : FSM_State<Anna>
{
    static readonly Anna_LastAttack_State instance = new Anna_LastAttack_State();
    public static Anna_LastAttack_State Instance
    {
        get { return instance; }
    }

    private bool OnSPMovePoint;
    private float circleSizeTimer = 0;
    private Vector3 CurrentPosition;
    private float circle_IntensityTimer = 0;
    private bool onetime = false;
    private float time; 

    public override void EnterState(Anna _Anna)
    {
        OnSPMovePoint = false;
        time = 0f;
        CurrentPosition = _Anna.transform.position;
        circleSizeTimer = 0;
        circle_IntensityTimer = 0;
        _Anna.Anna_Ani.Play("Idle");
        _Anna.Isinvincibility = true;
        onetime = false;
        _Anna.WorldEvent.GetComponent<Anna_WorldEvent>().LastMatch();

    }

    public override void ExitState(Anna _Anna)
    {
       
    }

    public override void UpdateState(Anna _Anna)
    {

        if (OnSPMovePoint == false)
        {
            var m_fMaxSpeed = _Anna.MoveSpeed;

            time += Time.deltaTime * m_fMaxSpeed;

            _Anna.transform.position = Vector3.Lerp(CurrentPosition, _Anna.SpMovePoint.transform.position, time);

            if (time >= 1.0f)
            {
                time = -2f;
                OnSPMovePoint = true;
            }
            return;
        }

        else
        {
            if (circleSizeTimer > 2.0f)
            {

            }
            else
            {
                circleSizeTimer += Time.deltaTime / _Anna.circleSizeSpeed;
            }
            _Anna.Circle.transform.localScale = new Vector3(circleSizeTimer, circleSizeTimer, circleSizeTimer);


            if (circle_IntensityTimer > 200)
            {

            }
            else
            {
                circle_IntensityTimer += Time.deltaTime * _Anna.circleIntensitySpeed;
            }
            _Anna.Circle.GetComponent<MeshRenderer>().material.SetFloat("_Color_Intensity", circle_IntensityTimer);


            if (_Anna.LastMatchClear == 5)
            {
                if (onetime == false)
                {
                    _Anna.ChangeState(Anna_Grogy_State.Instance);

                    onetime = true;
                }

            }
        }
    }

}
