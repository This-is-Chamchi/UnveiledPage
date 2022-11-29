using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_Protected_Attack : FSM_State<Anna>
{

    static readonly Anna_Protected_Attack instance = new Anna_Protected_Attack();
    public static Anna_Protected_Attack Instance
    {
        get { return instance; }
    }

    private bool oneTime;
    private float XposAlpha1;
    private float YposAlpha1;
    private float XposAlpha2;
    private float YposAlpha2;
    private Vector3 CurrentPosition;
    private Vector3 NextPosition1;
    private Vector3 NextPosition2;

    private Vector3 velocity = Vector3.zero;
    private float time = 0;

    public override void EnterState(Anna _Anna)
    {
        _Anna.AnnaSound("2StageAnna_MatchSummon");
        _Anna.AnnaSoundLoop("2StageAnna_Pattern2MatchRunning");
        _Anna.ProtectArea.gameObject.SetActive(true);
        _Anna.ProtectAreaActive = true;
        time = 0f;
        oneTime = false;

        _Anna.Anna_Ani.SetTrigger("Attack03_Start");

        //_Anna.Anna_Ani.SetTrigger("Move_Start");
        while (true)
        {
            _Anna.NextPosition1 = Random.Range(0, 5);
            if (_Anna.NextPosition1 != _Anna.CurrentPosiiton)
            {
                break;  //현재 위치가 아닌 다른위치
            }
        }


        while (true)
        {
            _Anna.NextPosition2 = Random.Range(0, 5);
            if (_Anna.NextPosition2 != _Anna.CurrentPosiiton && _Anna.NextPosition2 != _Anna.NextPosition1)
            {
                break;  //현재 위치가 아닌 다른위치
            }
        }

        CurrentPosition = _Anna.transform.position;

        XposAlpha1 = Random.Range(0.0f, _Anna.MoveRandomRange * 2);
        YposAlpha1 = Random.Range(0.0f, _Anna.MoveRandomRange * 2);
        XposAlpha2 = Random.Range(0.0f, _Anna.MoveRandomRange * 2);
        YposAlpha2 = Random.Range(0.0f, _Anna.MoveRandomRange * 2);

        NextPosition1 = _Anna.PatrolPoint[_Anna.NextPosition1].transform.position;
        NextPosition2 = _Anna.PatrolPoint[_Anna.NextPosition2].transform.position;

        NextPosition1.x -= _Anna.MoveRandomRange;
        NextPosition1.y -= _Anna.MoveRandomRange;

        NextPosition2.x -= _Anna.MoveRandomRange;
        NextPosition2.y -= _Anna.MoveRandomRange;

        NextPosition1.x += XposAlpha1;
        NextPosition1.y += YposAlpha1;

        NextPosition2.x += XposAlpha2;
        NextPosition2.y += YposAlpha2;

    }

    public override void UpdateState(Anna _Anna)
    {
        var m_fMaxSpeed = _Anna.MoveSpeed;

        if(_Anna.ProtectedMoveAble == true)
        {
            time += Time.deltaTime * m_fMaxSpeed;
        }

        _Anna.transform.position = GetBezierPosition(CurrentPosition, NextPosition1, NextPosition2, time);

        //Debug.Log(_Anna.transform.position);
        if (time >= 1.0f)
        {
            if (oneTime == false)
            {
                _Anna.Anna_Ani.SetTrigger("Move_End");
                oneTime = true;
            }
        }



    }

    public override void ExitState(Anna _Anna)
    {
        time = 0f;
        _Anna.ProtectArea.SetActive(false);
        _Anna.AnnaSoundLoopEnd("2StageAnna_Pattern2MatchRunning");
        _Anna.CurrentPosiiton = _Anna.NextPosition2;
        _Anna.ProtectedMoveAble = false;



    }
    private Vector3 GetBezierPosition(Vector3 p0, Vector3 p1, Vector3 p2, float t)
    {
        Vector3 q0 = Vector3.Lerp(p0, p1, t);
        Vector3 q1 = Vector3.Lerp(p1, p2, t);


        return Vector3.Lerp(q0, q1, t);
    }

}
